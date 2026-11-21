// AUTH-01 AC11 / NFR-04: run with `npm run emulator` (needs firebase-tools + Java).
import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-repforge',
    firestore: {
      rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, 'users/bob/sessions/s1'), { totalVolumeKg: 1000 });
    await setDoc(doc(db, 'catalog/exercises/items/plank'), { name: 'Plank' });
  });
});

const as = (uid) => env.authenticatedContext(uid).firestore();

describe('AUTH-01 AC11 Firestore rules', () => {
  test('a user can read and write their own data', async () => {
    const db = as('alice');
    await assertSucceeds(setDoc(doc(db, 'users/alice'), { units: 'kg' }));
    await assertSucceeds(setDoc(doc(db, 'users/alice/sessions/s1'), { n: 1 }));
    await assertSucceeds(getDoc(doc(db, 'users/alice/sessions/s1')));
  });

  test("a user cannot read or write another user's data", async () => {
    const db = as('alice');
    await assertFails(getDoc(doc(db, 'users/bob/sessions/s1')));
    await assertFails(setDoc(doc(db, 'users/bob/sessions/s2'), { n: 1 }));
    await assertFails(setDoc(doc(db, 'users/bob'), { units: 'lb' }));
  });

  test('signed-out requests are denied everywhere', async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, 'users/bob/sessions/s1')));
    await assertFails(getDoc(doc(db, 'catalog/exercises/items/plank')));
  });

  test('the catalog is read-only for signed-in users', async () => {
    const db = as('alice');
    await assertSucceeds(getDoc(doc(db, 'catalog/exercises/items/plank')));
    await assertFails(setDoc(doc(db, 'catalog/exercises/items/new'), { name: 'x' }));
  });

  test('nothing outside users/** and catalog/** is reachable', async () => {
    const db = as('alice');
    await assertFails(getDoc(doc(db, 'admin/config')));
    await assertFails(setDoc(doc(db, 'admin/config'), { x: 1 }));
  });
});
