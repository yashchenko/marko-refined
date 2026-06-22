const admin = require('firebase-admin');

// Подключаем ключ
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const TEACHER_ID = "AnnaGoncharik"; 
const PRICE = 300;

async function seedRandomJune() {
  console.log('🚀 Начинаем посев: 2 фиксированных + 18 рандомных слотов...');
  
  const batch = db.batch();
  const usedTimes = new Set();
  let slotsCreated = 0;

  // Вспомогательная функция для добавления слота
  function addSlotToBatch(dateObj) {
    const timeKey = dateObj.getTime();
    if (usedTimes.has(timeKey)) return false; // Защита от дубликатов
    
    usedTimes.add(timeKey);
    
    // Конец слота (+1 час)
    const slotEnd = new Date(dateObj);
    slotEnd.setHours(dateObj.getHours() + 1);

    const docRef = db.collection('timeSlots').doc();
    batch.set(docRef, {
      teacherId: TEACHER_ID,
      price: PRICE,
      isBooked: false,
      startTime: admin.firestore.Timestamp.fromDate(dateObj),
      endTime: admin.firestore.Timestamp.fromDate(slotEnd),
      bookedAt: null,
      bookedByUserId: null,
      bookingId: null
    });
    
    slotsCreated++;
    console.log(`⏳ Слот ${slotsCreated}/20: ${dateObj.toLocaleString()}`);
    return true;
  }

  // 1. ДОБАВЛЯЕМ 2 ОБЯЗАТЕЛЬНЫХ СЛОТА (17 июня 2026, 16:00 и 17:00)
  // Важно: в JS месяцы начинаются с 0, поэтому Июнь = 5
  const fixedSlot1 = new Date(2026, 5, 17, 16, 0, 0);
  const fixedSlot2 = new Date(2026, 5, 17, 17, 0, 0);
  
  addSlotToBatch(fixedSlot1);
  addSlotToBatch(fixedSlot2);

  // 2. ГЕНЕРИРУЕМ ОСТАЛЬНЫЕ 18 СЛОТОВ
  const startDate = new Date(2026, 5, 17, 0, 0, 0).getTime();
  const endDate = new Date(2026, 5, 30, 23, 59, 59).getTime();

  while (slotsCreated < 20) {
    const randomTimestamp = startDate + Math.random() * (endDate - startDate);
    const slotStart = new Date(randomTimestamp);
    
    slotStart.setMinutes(0, 0, 0, 0);
    
    // Исключаем воскресенье (0)
    if (slotStart.getDay() === 0) continue;
    
    // Рабочие часы (с 9 до 18)
    const hour = slotStart.getHours();
    if (hour < 9 || hour > 18) continue;

    addSlotToBatch(slotStart);
  }

  await batch.commit();
  console.log(`✅ Success! Успешно создано 20 слотов.`);
}

seedRandomJune().catch(console.error);