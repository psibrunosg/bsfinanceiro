import{z}from"zod";export const authSchema=z.object({email:z.string().email("Informe um e-mail válido."),password:z.string().min(8,"Use pelo menos 8 caracteres.")});
