// =====================================================================
// Configuração da ligação ao Supabase
// Supabase → Project Settings → API (ou "Data API")
//   supabaseUrl     = "Project URL"           (ex.: https://abcdefgh.supabase.co)
//   supabaseAnonKey = chave "anon" / "public"  (pode ser pública: a segurança
//                     é feita pelas regras da base de dados, não por esta chave)
// NUNCA coloque aqui a chave "service_role".
// Se deixar estes valores por preencher, a app funciona em modo local.
// =====================================================================
window.ESCALA_CONFIG = {
  supabaseUrl: 'https://COLOQUE-AQUI-O-SEU-PROJETO.supabase.co',
  supabaseAnonKey: 'COLOQUE_AQUI_A_CHAVE_ANON'
};
