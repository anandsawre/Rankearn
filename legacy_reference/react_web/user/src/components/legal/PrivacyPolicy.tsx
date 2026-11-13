import React from 'react';
import LegalLayout from './LegalLayout';

export default function PrivacyPolicy() {
  return (
    <LegalLayout
      title="Privacy Policy"
      subtitle="Rankearn Education Private Limited is committed to protecting your personal and financial data in compliance with Indian Information Technology laws."
      seoTitle="Privacy Policy - Rankearn Education"
      seoDescription="Read Rankearn's detailed Privacy Policy explaining how we collect, store, process, and protect your personal data under IT Act 2000 and SPDI Rules 2011."
      lastUpdated="May 24, 2026"
    >
      <section>
        <p className="legal-note">
          This Privacy Policy ("Policy") is published in compliance with Section 43A of the Information Technology Act, 2000 and Rule 4 of the Information Technology (Reasonable Security Practices and Procedures and Sensitive Personal Data or Information) Rules, 2011 (the "SPDI Rules"). It describes how Rankearn Education Private Limited ("Rankearn", "Company", "we", "us", or "our") collects, uses, stores, and protects your information when you access or use the Rankearn mobile application or website.
        </p>
      </section>

      <section>
        <h2>1. Information We Collect</h2>
        <p>
          To provide a seamless, secure, and personalized experience, we collect two categories of information from users:
        </p>
        
        <h3>1.1 Personal Information</h3>
        <p>
          This is information that can identify you directly or indirectly. It includes:
        </p>
        <ul>
          <li><strong>Registration Data:</strong> Your name, email address, mobile phone number, profile photo, and password.</li>
          <li><strong>Academic Preferences:</strong> The competitive exams you are preparing for (such as UPSC, SSC, Banking, etc.).</li>
          <li><strong>Device & Usage Data:</strong> IP address, device ID, operating system version, browser type, network operator, and app performance logs.</li>
          <li><strong>Location Information:</strong> We collect your location/state of residence to ensure compliance with regional gaming regulations in India (e.g., to restrict paid contest access in specific states).</li>
        </ul>

        <h3>1.2 Sensitive Personal Data or Information (SPDI)</h3>
        <p>
          In accordance with Rule 3 of the SPDI Rules, we collect the following sensitive data when you perform transaction or verification tasks on our platform:
        </p>
        <ul>
          <li><strong>Financial Credentials:</strong> Bank account numbers, IFSC codes, and UPI IDs for processing withdrawals (all credit/debit card details and net banking credentials for top-ups are processed directly by PCI-DSS compliant third-party payment gateways and are never stored on our servers).</li>
          <li><strong>Identity Verification Docs:</strong> Permanent Account Number (PAN) details and images, collected solely for tax compliance (TDS deductions under Section 194BA) and verification of age and identity.</li>
        </ul>
      </section>

      <section>
        <h2>2. Consent and Control</h2>
        <p>
          By creating an account, registering on our platform, or performing financial top-ups, you express consent to our collection, transfer, storage, and processing of your personal data as outlined in this Policy.
        </p>
        <ul>
          <li><strong>Right to Withdraw Consent:</strong> You have the right to withdraw your consent at any time. Withdrawal of consent must be sent in writing to <strong>rankearnhelp@gmail.com</strong>. Please note that withdrawing consent may lead to the suspension or termination of your account, as certain data is essential to provide services.</li>
          <li><strong>Data Rectification:</strong> You can review, update, or correct your personal information directly through your profile settings or by contacting support.</li>
        </ul>
      </section>

      <section>
        <h2>3. Purpose and Usage of Data</h2>
        <p>
          We use the collected information for the following specific purposes:
        </p>
        <ul>
          <li><strong>Service Delivery:</strong> To set up, operate, and maintain your account, conduct live contests, track quiz performance, and calculate leaderboards.</li>
          <li><strong>Transactions & Payouts:</strong> To process coin purchases, manage wallet balances, and transfer winnings to your bank account or UPI ID.</li>
          <li><strong>Compliance & Legal:</strong> To check state-specific restrictions, deduct applicable TDS, verify age/identity, and prevent fraudulent activity (such as cheating or multiple accounts).</li>
          <li><strong>Communications:</strong> To send OTPs for login, transaction receipt alerts, support responses, and updates regarding new test series or contests.</li>
        </ul>
      </section>

      <section>
        <h2>4. Data Retention</h2>
        <p>
          We retain your personal data and SPDI only for as long as:
        </p>
        <ul>
          <li>Your Rankearn account is active.</li>
          <li>It is necessary to fulfill the purposes for which it was collected (e.g., contest records).</li>
          <li>It is required to comply with statutory legal requirements under Indian law (such as tax compliance, accounting audits, and anti-money laundering records, which may require retention for up to 8 years).</li>
        </ul>
      </section>

      <section>
        <h2>5. Data Sharing and Disclosures</h2>
        <p>
          We do not sell, trade, or rent your personal data to third parties. We share information only in the following limited circumstances:
        </p>
        <ul>
          <li><strong>Service Providers:</strong> With trusted third-party vendors (such as payment gateways, SMS providers, cloud database providers, and security auditors) who assist us in operating our platform, under strict data confidentiality agreements.</li>
          <li><strong>Legal Obligation:</strong> When required by law, subpoena, or government authority (such as tax departments, law enforcement agencies, or cyber security cells) to protect the rights, safety, and sovereignty of India.</li>
        </ul>
      </section>

      <section>
        <h2>6. Security of Your Data</h2>
        <p>
          We implement reasonable security practices and procedures in compliance with Rule 8 of the SPDI Rules, which are aligned with international standards (such as secure HTTPS transfer, database encryption at rest, tokenized payment integration, and access controls). While we take every effort to secure your data, no internet transmission is 100% secure, and we cannot guarantee absolute security.
        </p>
      </section>

      <section>
        <h2>7. Grievance Redressal Mechanism</h2>
        <p>
          In accordance with the Information Technology Act, 2000 and Rule 5(9) of the SPDI Rules, the name and contact details of our Grievance Officer are published below. Any complaints regarding data privacy, security, or misuse should be directed to the Grievance Officer:
        </p>
        <div className="bg-slate-50 p-8 rounded-2xl border border-slate-200">
          <h3 className="mt-0! mb-2!">Grievance Officer: Mr. R. Kumar</h3>
          <p className="mb-1! font-bold">Rankearn Education Private Limited</p>
          <p className="mb-1!">East Champaran, Bihar, PIN Code: 845401</p>
          <p className="mb-1!"><strong>Email:</strong> rankearnhelp@gmail.com</p>
          <p className="mb-0!"><strong>Support Timing:</strong> Monday to Friday (10:00 AM to 6:00 PM IST)</p>
        </div>
        <p className="mt-6 text-sm text-slate-500 italic">
          The Grievance Officer shall investigate and redress all grievances within one month (30 days) from the date of receipt of the grievance.
        </p>
      </section>
    </LegalLayout>
  );
}
