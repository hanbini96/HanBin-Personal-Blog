import { useState } from 'react';
import { supabase } from '../lib/supabase';

/**
 * AuthPanel provides a basic email-based login using Supabase magic links.
 * The Supabase project must have "Email" auth enabled. Users enter their
 * email address, and Supabase sends them a one-time link to authenticate.
 */
export default function AuthPanel() {
  const [email, setEmail] = useState('');
  const [sent, setSent] = useState(false);

  const login = async () => {
    const { error } = await supabase.auth.signInWithOtp({ email });
    if (!error) {
      setSent(true);
    }
  };

  return (
    <div className="mt-6">
      <h2 className="font-medium">Admin Login</h2>
      {sent ? (
        <p>Check your email for the magic link.</p>
      ) : (
        <div className="flex gap-2">
          <input
            className="border px-2 py-1"
            type="email"
            placeholder="you@example.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <button className="px-3 py-1 border" onClick={login}>
            Send Link
          </button>
        </div>
      )}
    </div>
  );
}