import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const email = process.argv[2];

if (!email) {
  console.error('Usage: tsx scripts/setAdminClaim.ts <user-email>');
  process.exit(1);
}

const configuredServiceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
const serviceAccountPath = configuredServiceAccountPath
  ? resolve(process.cwd(), configuredServiceAccountPath)
  : resolve(__dirname, '../serviceAccountKey.json');

if (!existsSync(serviceAccountPath)) {
  console.error(`Error: Missing serviceAccountKey.json at ${serviceAccountPath}`);
  console.error('Set FIREBASE_SERVICE_ACCOUNT_PATH to a local JSON key path, or place the key in the project root for one-off local use.');
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(serviceAccountPath, 'utf8'));

// Initialize Firebase Admin SDK
initializeApp({
  credential: cert(serviceAccount)
});

async function setAdminClaim() {
  try {
    const auth = getAuth();
    
    // Get user by email
    const user = await auth.getUserByEmail(email);
    
    // Set admin custom claim
    await auth.setCustomUserClaims(user.uid, { admin: true });
    
    console.log(`Success! Admin claim has been set for ${email}.`);
    console.log('The user must sign out and sign back in for the changes to take effect on the frontend.');
  } catch (error) {
    console.error('Error assigning admin claim:', error);
  }
}

setAdminClaim();
