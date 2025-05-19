import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://dlafqgosvjlmdoewyybl.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsYWZxZ29zdmpsbWRvZXd5eWJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ2MTUzMjUsImV4cCI6MjA2MDE5MTMyNX0.8vvGRn3CBfBZXB-3Rxw_5703a48KeKl6l0UrC-wzU_s';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
