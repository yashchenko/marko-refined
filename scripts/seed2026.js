const admin = require('firebase-admin');

// Мы ищем ключ в той же папке
const serviceAccount = require('./serviceAccountKey.json');

// Инициализация
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Твои учителя
const TEACHERS = [
  { 
    id: "AnnaGoncharik", 
    price: 55, 
    // График: Пн (1), Ср (3), Пт (5)
    workDays: [1, 3, 5],
    hours: [10, 14, 16] 
  },
  { 
    id: "NbzpVGtdGRYpwgBb46DW", 
    price: 40, 
    // График: Вт (2), Чт (4)
    workDays: [2, 4],
    hours: [9, 11, 13, 18] 
  }
];

// ПЕРИОД: Январь 2026 - Апрель 2026
const START_DATE = new Date('2026-01-01T00:00:00');
const END_DATE = new Date('2026-04-01T00:00:00');

async function seed() {
  console.log('🚀 Starting seeding for 2026...');
  
  const batchArray = [];
  let batch = db.batch();
  let operationCount = 0;
  let totalSlots = 0;

  for (let d = new Date(START_DATE); d <= END_DATE; d.setDate(d.getDate() + 1)) {
    const dayOfWeek = d.getDay(); 

    for (const teacher of TEACHERS) {
      if (teacher.workDays.includes(dayOfWeek)) {
        for (const hour of teacher.hours) {
          
          const startTime = new Date(d);
          startTime.setHours(hour, 0, 0, 0);
          
          const endTime = new Date(startTime);
          endTime.setHours(hour + 1, 0, 0, 0);

          const docRef = db.collection('timeSlots').doc();

          const slotData = {
            teacherId: teacher.id,
            price: teacher.price,
            isBooked: false,
            startTime: admin.firestore.Timestamp.fromDate(startTime),
            endTime: admin.firestore.Timestamp.fromDate(endTime),
            bookedAt: null,
            bookedByUserId: null,
            bookingId: null
          };

          batch.set(docRef, slotData);
          operationCount++;
          totalSlots++;

          if (operationCount >= 400) {
            batchArray.push(batch.commit());
            batch = db.batch();
            operationCount = 0;
            console.log(`... prepared batch of slots`);
          }
        }
      }
    }
  }

  if (operationCount > 0) {
    batchArray.push(batch.commit());
  }

  await Promise.all(batchArray);
  console.log(`✅ Success! Created ${totalSlots} time slots for 2026.`);
}

seed().catch(console.error);
