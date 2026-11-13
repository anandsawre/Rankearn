import React from 'react';
import LegalLayout from './LegalLayout';

export default function RefundPolicy() {
  return (
    <LegalLayout
      title="Refund & Cancellation Policy"
      subtitle="Rankearn Education Private Limited ensures a transparent, secure, and fair refund process in compliance with Indian laws."
      seoTitle="Refund & Cancellation Policy - Rankearn Education"
      seoDescription="Read Rankearn's Refund, Cancellation, and Wallet Policy detailing transaction policies, failed payment refunds, and TDS rules under Indian Laws."
      lastUpdated="May 24, 2026"
    >
      <section>
        <p className="legal-note">
          This Refund & Cancellation Policy ("Policy") governs all financial transactions, deposits, purchase of virtual coins, and withdrawals on the Rankearn platform. This Policy is designed in compliance with the Consumer Protection (E-Commerce) Rules, 2020, and other applicable financial regulations in India.
        </p>
      </section>

      <section>
        <h2>1. Nature of Services and Virtual Currency (Coins)</h2>
        <p>
          Rankearn is an educational platform offering skill-based contests, quizzes, and test series. To facilitate participation, the platform uses a virtual system:
        </p>
        <ul>
          <li><strong>Purchased Coins:</strong> Coins purchased by the user via secure third-party payment gateways are credited to the user's wallet instantly. Once credited, these purchases are considered consumed digital goods. Therefore, successful purchases of Coins are <strong>non-refundable</strong> and cannot be reverted to cash.</li>
          <li><strong>Earned/Winnings Coins:</strong> Coins won by participating in and winning contests can be converted to INR and withdrawn, subject to KYC verification, withdrawal fees, and applicable tax deductions (such as TDS).</li>
          <li><strong>Bonus/Promotional Coins:</strong> Coins received as sign-up bonuses, referral rewards, or promotional campaigns cannot be withdrawn as cash and are non-refundable. They can only be used to participate in contests on the platform.</li>
        </ul>
      </section>

      <section>
        <h2>2. Contest Entry Fees & Cancellations</h2>
        <p>
          Once a user enters a contest or purchases a test series, the entry fee (in Coins) is deducted from their wallet. 
        </p>
        <ul>
          <li><strong>User Voluntary Exit:</strong> If a user fails to attend, leaves, or gets disconnected from a contest once it begins due to user-end issues (e.g., poor internet, phone battery, app closure), no refund of the entry fee will be provided.</li>
          <li><strong>Platform Technical Failures:</strong> In the rare event that a contest cannot be conducted, is interrupted midway, or results cannot be declared due to a server failure, bug, or technical outage on Rankearn's end:
            <ul>
              <li>The entry fee (Coins) will be fully refunded to the user's Rankearn wallet within 24 to 48 hours.</li>
              <li>If direct monetary transaction issues occurred on a purchase that failed due to a system error, the amount will be processed for refund.</li>
            </ul>
          </li>
        </ul>
      </section>

      <section>
        <h2>3. Failed, Duplicate, or Erroneous Transactions</h2>
        <p>
          Occasionally, payments may fail at the gateway level where money is debited from your bank account/UPI but not credited to your Rankearn wallet:
        </p>
        <ul>
          <li><strong>Automatic Reversals:</strong> In most cases, the payment gateway provider or your bank will automatically reverse such transactions and refund the amount to your account within 3 to 5 business days.</li>
          <li><strong>Manual Verification:</strong> If the coins are not credited and the money is not returned within 5 business days, please write to us at <strong>rankearnhelp@gmail.com</strong> with the transaction receipt, UTR number, and screenshot. Upon validation, we will manually resolve the issue within 48 business hours, either by crediting the coins or initiating a manual refund.</li>
        </ul>
      </section>

      <section>
        <h2>4. Withdrawal Rules and Taxation (TDS)</h2>
        <p>
          Winnings can be withdrawn to a verified Indian bank account or UPI ID. The withdrawal process is subject to the following rules:
        </p>
        <ul>
          <li><strong>KYC Verification:</strong> Users must complete their profile and verification (including PAN and bank details, where applicable) before initiating a withdrawal to prevent money laundering and identity fraud.</li>
          <li><strong>TDS Deductions (Section 194BA):</strong> In accordance with Section 194BA of the Income Tax Act, 1961, TDS (Tax Deducted at Source) at the rate of 30% (or the prevailing rate) will be deducted from the user's "Net Winnings" at the time of withdrawal or at the end of the financial year. The company will issue TDS certificates for all deductions.</li>
          <li><strong>Processing Timelines:</strong> Withdrawal requests are verified and processed within 1 to 3 business days. The company is not liable for delay caused by bank servers, national holidays, or incorrect bank/UPI details entered by the user.</li>
        </ul>
      </section>

      <section>
        <h2>5. Account Suspension and Forfeiture</h2>
        <p>
          If a user account is suspended or terminated due to violation of the Terms of Use (such as cheating, using bots, multiple account creation, or payment fraud):
        </p>
        <ul>
          <li>All balances (including purchased, earned, and promotional coins) in the user's wallet shall be forfeited.</li>
          <li>No refunds will be granted for any deposits made by the violating user.</li>
        </ul>
      </section>

      <section>
        <h2>6. Support and Grievance</h2>
        <p>
          For any payment or refund queries, please reach out to our team at <strong>rankearnhelp@gmail.com</strong>. All support requests are logged and reviewed by our Nodal Officer. We aim to address and resolve all billing and refund issues within 15 working days.
        </p>
      </section>
    </LegalLayout>
  );
}
