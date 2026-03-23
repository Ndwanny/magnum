// Supabase Edge Function: payment-webhook
// Receives Lenco/Broadpay payment status webhooks and updates the database.
// Deploy: supabase functions deploy payment-webhook
//
// Set the webhook URL in Lenco dashboard to:
//   https://<your-project-ref>.supabase.co/functions/v1/payment-webhook

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { hmac } from 'https://deno.land/x/hmac@v2.0.1/mod.ts';

const WEBHOOK_SECRET       = Deno.env.get('LENCO_WEBHOOK_SECRET')!;
const SUPABASE_URL         = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req: Request) => {
  // Only accept POST
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const rawBody = await req.text();

  // ── Verify Lenco signature ──────────────────────────────
  const signature = req.headers.get('x-broadpay-signature') ?? req.headers.get('x-lenco-signature') ?? '';
  const expectedSig = await hmac('sha256', WEBHOOK_SECRET, rawBody, 'utf8', 'hex');
  if (signature !== expectedSig) {
    console.warn('Invalid webhook signature');
    return new Response('Unauthorized', { status: 401 });
  }

  let payload: Record<string, unknown>;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return new Response('Invalid JSON', { status: 400 });
  }

  const txId       = payload.transaction_id as string;
  const status     = payload.status as string;          // 'completed' | 'failed' | 'cancelled'
  const invoiceRef = payload.merchant_reference as string;
  const amount     = payload.amount as number;
  const method     = payload.payment_method as string;
  const failureMsg = payload.failure_reason as string | undefined;

  // Use service role key — this bypasses RLS for webhook updates
  const sb = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

  // ── Update payment_transactions ──────────────────────────
  await sb.from('payment_transactions').update({
    status,
    lenco_tx_id:     txId,
    failure_reason:  failureMsg,
    webhook_payload: payload,
    completed_at:    status === 'completed' ? new Date().toISOString() : null,
  }).eq('lenco_tx_id', txId);

  // ── If completed, mark invoice as Paid ───────────────────
  if (status === 'completed' || status === 'successful') {
    await sb.from('invoices').update({
      status:         'Paid',
      payment_method: method,
      payment_ref:    invoiceRef,
      lenco_tx_id:    txId,
      paid_at:        new Date().toISOString(),
    }).eq('invoice_number', invoiceRef);

    // ── Send payment confirmation email ───────────────────
    // Fetch invoice + client details for the email
    const { data: invoice } = await sb
      .from('invoices')
      .select('client_name, amount, invoice_number, profiles(email:id)')
      .eq('invoice_number', invoiceRef)
      .single();

    if (invoice) {
      await sb.functions.invoke('send-email', {
        body: {
          template: 'payment_confirmation',
          to: (invoice as any).client_email ?? '',
          data: {
            client_name:    invoice.client_name,
            invoice_number: invoice.invoice_number,
            amount:         Number(invoice.amount).toFixed(2),
            payment_method: method,
            tx_ref:         txId,
            paid_at:        new Date().toISOString(),
          },
        },
      });
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
