const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

// ✅ ВАЖЛИВО: для Node.js 18 та firebase-functions 4.x
// region() потрібно викликати окремо, не через exports
const regionalFunctions = functions.region('europe-west1');

/**
 * 🎓 Cloud Function для обработки платежа за урок
 * Вызывается из iOS приложения после успешной оплаты
 * 
 * Что делает:
 * 1. Получает актуальные налоговые ставки из Firestore
 * 2. Рассчитывает все налоги и комиссии
 * 3. Создаёт запись в payout_ledger (для бухгалтерии)
 * 4. Обновляет статус урока на "upcoming"
 */
exports.processPayment = regionalFunctions.https.onCall(async (data, context) => {
  
  // === ПРОВЕРКА АВТОРИЗАЦИИ ===
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated', 
      'Користувач не авторизований. Увійдіть в систему.'
    );
  }
  
  const userId = context.auth.uid;
  const { lessonId, amountReceived, paymentIntentId } = data;
  
  // === ВАЛИДАЦИЯ ДАННЫХ ===
  if (!lessonId || !amountReceived || !paymentIntentId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Відсутні обов\'язкові параметри: lessonId, amountReceived, paymentIntentId'
    );
  }
  
  if (amountReceived <= 0) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Сума платежу повинна бути більше 0'
    );
  }
  
  console.log(`📝 Початок обробки платежу для уроку ${lessonId}`);
  console.log(`💰 Сума отримана: ${amountReceived} грн`);
  
  try {
    // === ШАГ 1: ПОЛУЧИТЬ КОНФИГУРАЦИЮ НАЛОГОВ ===
    const taxConfigSnapshot = await db
      .collection('tax_configurations')
      .doc('current')
      .get();
    
    if (!taxConfigSnapshot.exists) {
      console.error('❌ Конфігурація податків не знайдена');
      throw new functions.https.HttpsError(
        'not-found', 
        'Конфігурація податків не знайдена. Зверніться до адміністратора.'
      );
    }
    
    const taxConfig = taxConfigSnapshot.data();
    console.log('✅ Конфігурація податків завантажена');
    
    // === ШАГ 2: ПОЛУЧИТЬ УРОК ===
    const lessonDoc = await db.collection('lessons').doc(lessonId).get();
    
    if (!lessonDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        'Урок не знайдено в базі даних'
      );
    }
    
    const lesson = lessonDoc.data();
    
    // Проверка что урок принадлежит пользователю
    if (lesson.userId !== userId) {
      throw new functions.https.HttpsError(
        'permission-denied',
        'Ви не маєте доступу до цього уроку'
      );
    }
    
    console.log('✅ Урок знайдено');
    console.log(`👨‍🏫 Вчитель: ${lesson.teacherId}`);
    console.log(`👨‍🎓 Студент: ${lesson.userId}`);
    
    // === ШАГ 3: ФИНАНСОВЫЕ РАСЧЁТЫ ===
    console.log('🧮 Початок розрахунків...');
    
    // 3.1 Комиссия платформы (10%)
    const platformCommission = amountReceived * taxConfig.platformCommissionRate;
    console.log(`💼 Комісія платформи (${taxConfig.platformCommissionRate * 100}%): ${platformCommission.toFixed(2)} грн`);
    
    // 3.2 Налоги школы ФОП 3 группа (6% = 5% єдиний + 1% військовий)
    const platformTaxes = amountReceived * (taxConfig.fopTaxRate + taxConfig.fopMilitaryTaxRate);
    console.log(`🏛️ Податки школи (${(taxConfig.fopTaxRate + taxConfig.fopMilitaryTaxRate) * 100}%): ${platformTaxes.toFixed(2)} грн`);
    
    // 3.3 Валовая выплата учителю
    const grossPayoutToTeacher = amountReceived - platformCommission - platformTaxes;
    console.log(`💵 Валова виплата вчителю: ${grossPayoutToTeacher.toFixed(2)} грн`);
    
    // 3.4 Удержания из выплаты учителю (ЦПД)
    const teacherPDFO = grossPayoutToTeacher * taxConfig.teacherPDFORate;
    const teacherMilitaryTax = grossPayoutToTeacher * taxConfig.teacherMilitaryTaxRate;
    console.log(`📊 ПДФО вчителя (${taxConfig.teacherPDFORate * 100}%): ${teacherPDFO.toFixed(2)} грн`);
    console.log(`🪖 Військовий збір вчителя (${taxConfig.teacherMilitaryTaxRate * 100}%): ${teacherMilitaryTax.toFixed(2)} грн`);
    
    // 3.5 Чистая выплата учителю
    const netPayoutToTeacher = grossPayoutToTeacher - teacherPDFO - teacherMilitaryTax;
    console.log(`✅ Чиста виплата вчителю: ${netPayoutToTeacher.toFixed(2)} грн`);
    
    // 3.6 ЄСВ школа платит сверху
    const schoolESVContribution = grossPayoutToTeacher * taxConfig.teacherESVRate;
    console.log(`🏥 ЄСВ (платить школа) (${taxConfig.teacherESVRate * 100}%): ${schoolESVContribution.toFixed(2)} грн`);
    
    // === ШАГ 4: СОЗДАТЬ ЗАПИСЬ В PAYOUT_LEDGER ===
    const ledgerEntry = {
      lessonId: lessonId,
      teacherId: lesson.teacherId,
      studentId: lesson.userId,
      transactionDate: admin.firestore.Timestamp.now(),
      
      amountPaidByStudent: amountReceived,
      paymentProcessingFee: 0,
      amountReceived: amountReceived,
      
      platformCommission: platformCommission,
      platformTaxes: platformTaxes,
      
      grossPayoutToTeacher: grossPayoutToTeacher,
      teacherPDFO: teacherPDFO,
      teacherMilitaryTax: teacherMilitaryTax,
      netPayoutToTeacher: netPayoutToTeacher,
      
      schoolESVContribution: schoolESVContribution,
      
      taxConfigId: 'current',
      appliedRates: {
        platformCommissionRate: taxConfig.platformCommissionRate,
        fopTaxRate: taxConfig.fopTaxRate,
        fopMilitaryTaxRate: taxConfig.fopMilitaryTaxRate,
        teacherPDFORate: taxConfig.teacherPDFORate,
        teacherMilitaryTaxRate: taxConfig.teacherMilitaryTaxRate,
        teacherESVRate: taxConfig.teacherESVRate
      },
      
      currency: 'UAH',
      payoutStatus: 'pending',
      payoutDate: null,
      paymentIntentId: paymentIntentId,
      createdAt: admin.firestore.Timestamp.now()
    };
    
    // === ШАГ 5: АТОМАРНАЯ ТРАНЗАКЦИЯ ===
    let ledgerEntryId = null;
    
    await db.runTransaction(async (transaction) => {
      const ledgerRef = db.collection('payout_ledger').doc();
      ledgerEntryId = ledgerRef.id;
      
      const lessonRef = db.collection('lessons').doc(lessonId);
      const lessonSnapshot = await transaction.get(lessonRef);
      if (lessonSnapshot.data().paymentCompleted === true) {
        throw new Error('Цей урок вже оплачено');
      }
      
      transaction.set(ledgerRef, ledgerEntry);
      
      transaction.update(lessonRef, { 
        status: 'upcoming',
        paymentCompleted: true,
        paymentIntentId: paymentIntentId,
        paymentCompletedAt: admin.firestore.Timestamp.now()
      });
    });
    
    console.log(`✅ Транзакція успішна! ID запису: ${ledgerEntryId}`);
    
    return {
      success: true,
      ledgerEntryId: ledgerEntryId,
      netPayoutToTeacher: netPayoutToTeacher,
      message: 'Платіж успішно оброблено'
    };
    
  } catch (error) {
    console.error('❌ Помилка обробки платежу:', error);
    
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    
    throw new functions.https.HttpsError(
      'internal',
      `Помилка обробки платежу: ${error.message}`
    );
  }
});

/**
 * 🔧 Вспомогательная функция для тестирования
 * Можно вызвать из Firebase Console
 */
exports.testCalculations = regionalFunctions.https.onRequest(async (req, res) => {
  const amountReceived = 1000; // тестовая сумма
  
  try {
    const taxConfig = await db.collection('tax_configurations').doc('current').get();
    
    if (!taxConfig.exists) {
      res.status(404).send('Tax configuration not found');
      return;
    }
    
    const config = taxConfig.data();
    
    const platformCommission = amountReceived * config.platformCommissionRate;
    const platformTaxes = amountReceived * (config.fopTaxRate + config.fopMilitaryTaxRate);
    const grossPayoutToTeacher = amountReceived - platformCommission - platformTaxes;
    const teacherPDFO = grossPayoutToTeacher * config.teacherPDFORate;
    const teacherMilitaryTax = grossPayoutToTeacher * config.teacherMilitaryTaxRate;
    const netPayoutToTeacher = grossPayoutToTeacher - teacherPDFO - teacherMilitaryTax;
    const schoolESVContribution = grossPayoutToTeacher * config.teacherESVRate;
    
    res.json({
      amountReceived,
      platformCommission,
      platformTaxes,
      grossPayoutToTeacher,
      teacherPDFO,
      teacherMilitaryTax,
      netPayoutToTeacher,
      schoolESVContribution
    });
    
  } catch (error) {
    res.status(500).send(error.message);
  }
});

