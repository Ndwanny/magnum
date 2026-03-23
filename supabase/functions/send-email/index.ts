// Supabase Edge Function: send-email
// Uses Resend (resend.com) to send transactional emails.
// Deploy: supabase functions deploy send-email

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const FROM_EMAIL     = Deno.env.get('FROM_EMAIL') ?? 'noreply@magnumsecurity.co.zm';
const FROM_NAME      = 'Magnum Security';

interface EmailRequest {
  template: string;
  to: string;
  data: Record<string, unknown>;
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    });
  }

  try {
    const { template, to, data }: EmailRequest = await req.json();
    const { subject, html } = buildEmail(template, data);

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: `${FROM_NAME} <${FROM_EMAIL}>`,
        to: [to],
        subject,
        html,
      }),
    });

    const result = await res.json();
    if (!res.ok) throw new Error(result.message ?? 'Resend error');

    return new Response(JSON.stringify({ success: true, id: result.id }), {
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error('send-email error:', err);
    return new Response(JSON.stringify({ success: false, error: String(err) }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});

// ── Email templates ───────────────────────────────────────────
function buildEmail(template: string, d: Record<string, unknown>): { subject: string; html: string } {
  const base = (content: string) => `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background:#0A1628; margin:0; padding:20px; }
        .card { background:#1A2942; border-radius:12px; padding:32px; max-width:560px; margin:0 auto; }
        .logo { display:flex; align-items:center; gap:10px; margin-bottom:24px; }
        .logo-icon { background:linear-gradient(135deg,#C9A84C,#9E7C2E); width:40px; height:40px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:20px; }
        .logo-text { color:#fff; font-size:18px; font-weight:700; }
        h2 { color:#fff; margin:0 0 8px; }
        p { color:#B0BEC5; line-height:1.6; margin:8px 0; }
        .badge { display:inline-block; padding:4px 10px; border-radius:4px; font-size:12px; font-weight:700; }
        .badge-gold { background:rgba(201,168,76,0.15); color:#C9A84C; }
        .badge-red { background:rgba(244,67,54,0.15); color:#F44336; }
        .badge-green { background:rgba(76,175,80,0.15); color:#4CAF50; }
        .btn { display:inline-block; background:#C9A84C; color:#000; padding:12px 24px; border-radius:8px; text-decoration:none; font-weight:700; margin-top:16px; }
        .divider { border:none; border-top:1px solid #2A3F5F; margin:20px 0; }
        .row { display:flex; justify-content:space-between; margin:6px 0; }
        .label { color:#607D8B; font-size:13px; }
        .value { color:#fff; font-size:13px; font-weight:500; }
        .footer { text-align:center; margin-top:24px; color:#607D8B; font-size:11px; }
      </style>
    </head>
    <body>
      <div class="card">
        <div class="logo">
          <div class="logo-icon">🛡️</div>
          <span class="logo-text">Magnum Security</span>
        </div>
        ${content}
        <hr class="divider">
        <div class="footer">
          Magnum Security Ltd · Plot 12, Cairo Road, Lusaka, Zambia<br>
          ZAPS Lic. ZS-2024-0042 · PSAZ Member No. 0178<br>
          Emergency: <strong style="color:#F44336">0800 123 456</strong>
        </div>
      </div>
    </body>
    </html>`;

  switch (template) {
    case 'contact_notification':
      return {
        subject: `New Contact Message — ${d.from_name}`,
        html: base(`
          <h2>New Contact Form Submission</h2>
          <p><strong style="color:#fff">${d.from_name}</strong> sent a message via the website contact form.</p>
          <hr class="divider">
          <div class="row"><span class="label">Name</span><span class="value">${d.from_name}</span></div>
          <div class="row"><span class="label">Email</span><span class="value">${d.from_email}</span></div>
          <div class="row"><span class="label">Phone</span><span class="value">${d.phone}</span></div>
          <hr class="divider">
          <p style="color:#fff;font-weight:600">Message:</p>
          <p style="background:#0F1E38;padding:16px;border-radius:8px;color:#B0BEC5">${d.message}</p>
          <p style="color:#607D8B;font-size:12px">Submitted: ${new Date(d.submitted_at as string).toLocaleString('en-ZM')}</p>
        `),
      };

    case 'quote_notification':
      return {
        subject: `New Quote Request — ${d.company} (${d.service_type})`,
        html: base(`
          <h2>New Quote Request</h2>
          <span class="badge badge-gold">${d.service_type}</span>
          <hr class="divider">
          <div class="row"><span class="label">Contact</span><span class="value">${d.name}</span></div>
          <div class="row"><span class="label">Company</span><span class="value">${d.company}</span></div>
          <div class="row"><span class="label">Email</span><span class="value">${d.email}</span></div>
          <div class="row"><span class="label">Phone</span><span class="value">${d.phone}</span></div>
          <div class="row"><span class="label">Guards Needed</span><span class="value">${d.guards_needed}</span></div>
          <div class="row"><span class="label">Site Address</span><span class="value">${d.site_address}</span></div>
          ${d.notes ? `<div class="row"><span class="label">Notes</span><span class="value">${d.notes}</span></div>` : ''}
          <a href="https://portal.magnumsecurity.co.zm/admin/crm" class="btn">Open CRM →</a>
        `),
      };

    case 'quote_confirmation':
      return {
        subject: 'Quote Request Received — Magnum Security',
        html: base(`
          <h2>Thank you, ${d.name}!</h2>
          <p>We have received your security quote request for <strong style="color:#C9A84C">${d.company}</strong>.</p>
          <p>A Magnum Security consultant will contact you within <strong style="color:#fff">24 hours</strong> with a personalised proposal and pricing in ZMW.</p>
          <p>Service requested: <span class="badge badge-gold">${d.service_type}</span></p>
          <hr class="divider">
          <p>For urgent enquiries:</p>
          <p>📞 <strong style="color:#fff">+260 977 123 456</strong></p>
          <p>🚨 Emergency: <strong style="color:#F44336">0800 123 456</strong> (24/7 free)</p>
        `),
      };

    case 'invoice':
      return {
        subject: `Invoice ${d.invoice_number} — ZMW ${d.amount}`,
        html: base(`
          <h2>Invoice from Magnum Security</h2>
          <p>Dear ${d.client_name},</p>
          <p>Please find your invoice details below.</p>
          <hr class="divider">
          <div class="row"><span class="label">Invoice No.</span><span class="value">${d.invoice_number}</span></div>
          <div class="row"><span class="label">Amount</span><span class="value" style="color:#C9A84C;font-weight:700">ZMW ${d.amount}</span></div>
          <div class="row"><span class="label">Due Date</span><span class="value">${d.due_date}</span></div>
          <hr class="divider">
          <a href="${d.portal_url}" class="btn">Pay Now →</a>
          <p style="margin-top:16px">Accepted: MTN Mobile Money · Airtel Money · Card · Bank Transfer</p>
        `),
      };

    case 'invoice_overdue':
      return {
        subject: `⚠️ Overdue Invoice ${d.invoice_number} — Action Required`,
        html: base(`
          <h2>Invoice Overdue</h2>
          <p>Dear ${d.client_name},</p>
          <p>Invoice <strong style="color:#fff">${d.invoice_number}</strong> for <strong style="color:#C9A84C">ZMW ${d.amount}</strong> is now <span class="badge badge-red">${d.days_overdue} days overdue</span>.</p>
          <p>Please make payment as soon as possible to avoid service interruption.</p>
          <a href="${d.payment_url}" class="btn">Pay Now →</a>
          <hr class="divider">
          <p>Questions? Contact billing:<br>
          📧 ${d.support_email}<br>
          📞 ${d.support_phone}</p>
        `),
      };

    case 'payment_confirmation':
      return {
        subject: `Payment Confirmed — ${d.invoice_number}`,
        html: base(`
          <h2>✅ Payment Received</h2>
          <p>Dear ${d.client_name}, your payment has been confirmed.</p>
          <hr class="divider">
          <div class="row"><span class="label">Invoice</span><span class="value">${d.invoice_number}</span></div>
          <div class="row"><span class="label">Amount Paid</span><span class="value" style="color:#4CAF50;font-weight:700">ZMW ${d.amount}</span></div>
          <div class="row"><span class="label">Method</span><span class="value">${d.payment_method}</span></div>
          <div class="row"><span class="label">Reference</span><span class="value">${d.tx_ref}</span></div>
          <div class="row"><span class="label">Date</span><span class="value">${new Date(d.paid_at as string).toLocaleString('en-ZM')}</span></div>
          <p style="margin-top:16px"><span class="badge badge-green">PAID</span></p>
          <p>Thank you for your business. Your security services continue uninterrupted.</p>
        `),
      };

    case 'incident_alert':
      return {
        subject: `🚨 Incident Alert — ${d.site_name} [${d.severity}]`,
        html: base(`
          <h2>🚨 Incident Alert</h2>
          <p>Dear ${d.client_name}, an incident has been reported at your site.</p>
          <hr class="divider">
          <div class="row"><span class="label">Site</span><span class="value">${d.site_name}</span></div>
          <div class="row"><span class="label">Incident</span><span class="value">${d.incident_title}</span></div>
          <div class="row"><span class="label">Severity</span><span class="value"><span class="badge badge-red">${d.severity}</span></span></div>
          <div class="row"><span class="label">Guard</span><span class="value">${d.responding_guard}</span></div>
          <div class="row"><span class="label">Time</span><span class="value">${new Date(d.reported_at as string).toLocaleString('en-ZM')}</span></div>
          <a href="${d.portal_url}" class="btn">View in Portal →</a>
          <hr class="divider">
          <p>🚨 Emergency line: <strong style="color:#F44336">0800 123 456</strong></p>
        `),
      };

    default:
      return { subject: 'Magnum Security Notification', html: base('<p>Notification from Magnum Security.</p>') };
  }
}
