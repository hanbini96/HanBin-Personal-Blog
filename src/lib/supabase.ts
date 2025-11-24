import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) {
  // console.error('PUBLIC_SUPABASE_URL is missing at build time');
  throw new Error('PUBLIC_SUPABASE_URL is not set');
}

if (!supabaseAnonKey) {
  // console.error('PUBLIC_SUPABASE_ANON_KEY is missing at build time');
  throw new Error('PUBLIC_SUPABASE_ANON_KEY is not set');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
