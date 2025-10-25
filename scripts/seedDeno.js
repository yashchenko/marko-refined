// file: scripts/seedDeno.js

import { initializeApp, cert } from "npm:firebase-admin@11.11.1/app";
import { getFirestore } from "npm:firebase-admin@11.11.1/firestore";

// This is a polyfill for process.nextTick which Deno doesn't have.
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
  await deleteCollection(db, 'timeSlots', 100);
  console.log('--- Existing timeSlots deleted. Starting to seed new data... ---');

  const batch = db.batch();
  let slotCount = 0;

  for (let i = 0; i < 50; i++) {
    const date = new Date();
    date.setHours(0, 0, 0, 0); // Start at the beginning of the day
    date.setDate(date.getDate() + i);

    if (date.getDay() === 1) { // 1 = Monday
      addSlotToBatch(batch, teacherIds.anna, date, 14, 300); // 2 PM
      addSlotToBatch(batch, teacherIds.anna, date, 17, 300); // 5 PM
      slotCount += 2;
    } else {
      const randomHours = new Set();
      while (randomHours.size < 2) {
        const hour = Math.floor(Math.random() * 10) + 9; // Random hour from 9 to 18
        randomHours.add(hour);
      }
      
      randomHours.forEach(hour => {
        addSlotToBatch(batch, teacherIds.emma, date, hour, 400);
        slotCount++;
      });
    }
  }

  await batch.commit();
  console.log(`--- Successfully seeded ${slotCount} new time slots. ---`);
}

function addSlotToBatch(batch, teacherId, date, hour, price) {
  const startTime = new Date(date);
  startTime.setHours(hour, 0, 0, 0);
  const endTime = new Date(startTime);
  endTime.setHours(startTime.getHours() + 1);

  const isBooked = Math.random() < 0.1;

  const newSlotRef = timeSlotsCollection.doc();
  batch.set(newSlotRef, {
    teacherId: teacherId,
    startTime: startTime,
    endTime: endTime,
    price: price,
    isBooked: isBooked,
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

  // Use the Deno-compatible polyfill
  nextTick(() => {
    deleteQueryBatch(db, query, resolve);
  });
}

await seedDatabase();
