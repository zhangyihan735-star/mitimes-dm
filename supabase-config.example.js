// 复制为 supabase-config.js，填写 Supabase 控制台 Project Settings > API 中的值。
// anon key 可以放在前端；安全性依靠数据库 RLS 策略，不要把 service_role key 放进网站。
window.SUPABASE_CONFIG = {
  url: 'https://YOUR_PROJECT_REF.supabase.co',
  anonKey: 'YOUR_SUPABASE_ANON_KEY'
};
