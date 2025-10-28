// FINAL FINAL VERSION
import { initializeApp, cert } from "npm:firebase-admin@11.11.1/app";
import { getFirestore } from "npm:firebase-admin@11.11.1/firestore";

const nextTick = (callback) => Promise.resolve().then(callback);
const serviceAccount = JSON.parse(await Deno.readTextFile("./serviceAccountKey.json"));

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const timeSlotsCollection = db.collection('timeSlots');

const teacherIds = {
  anna: "AnnaGoncharik",
  emma: "NbzpVGtdGRYpwgBb46DW"
};

async function seedDatabase() {
  console.log('--- Deleting existing timeSlots collection... ---');
  await deleteCollection(db, 'timeSlots', 200);
  console.log('--- Existing timeSlots deleted. Starting to seed new data... ---');

  const batch = db.batch();
  let slotCount = 0;
  const startDate = new Date("2025-11-01T00:00:00Z");

  for (let i = 0; i < 60; i++) {
    const currentDate = new Date(startDate);
    currentDate.setUTCDate(startDate.getUTCDate() + i);

    if (currentDate.getUTCDay() === 1) { // 1 = Monday
      addSlotToBatch(batch, teacherIds.anna, currentDate, 14, 300);
      addSlotToBatch(batch, teacherIds.anna, currentDate, 17, 300);
      slotCount += 2;
    } else {
      const randomHours = new Set();
      while (randomHours.size < 2) {
        const hour = Math.floor(Math.random() * 10) + 9;
        randomHours.add(hour);
      }
      
      randomHours.forEach(hour => {
        addSlotToBatch(batch, teacherIds.emma, currentDate, hour, 400);
        slotCount++;
      });
    }
  }

  await batch.commit();
  console.log(`--- Successfully seeded ${slotCount} new time slots. ---`);
}

function addSlotToBatch(batch, teacherId, date, hour, price) {
  const startTime = new Date(date);
  startTime.setUTCHours(hour, 0, 0, 0);
  const endTime = new Date(startTime);
  endTime.setUTCHours(startTime.getUTCHours() + 1);
  const isBooked = Math.random() < 0.1;

  const newSlotRef = timeSlotsCollection.doc();
  batch.set(newSlotRef, {
    teacherId,
    startTime,
    endTime,
    price,
    isBooked,
    bookedByUserId: isBooked ? `student_${Math.floor(Math.random() * 1000)}` : null,
    bookingId: isBooked ? crypto.randomUUID() : null,
    bookedAt: isBooked ? new Date() : null
  });
}

async function deleteCollection(db, collectionPath, batchSize) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.orderBy('__name__').limit(batchSize);
  return new Promise((resolve, reject) => {
    deleteQueryBatch(db, query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(db, query, resolve) {
  const snapshot = await query.get();
  if (snapshot.size === 0) {
    return resolve();
  }
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

await seedDatabase();
