// api-functions/news.ts

import { RouterContext } from 'oak';
import { News } from '../interfaces/news.interface.ts';
import { FirestoreBaseUrl } from './utils.ts';

// const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID");
const FirestoreNewsURL = FirestoreBaseUrl + '/news';

// Crear noticia
export async function createNews(ctx: RouterContext<'/api/createNews'>) {
  console.log('Creando noticia...');
  const { value } = await ctx.request.body({ type: 'json' });
  const news: News = await value;

  const response = await fetch(FirestoreNewsURL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      fields: {
        title: { stringValue: news.title },
        text: { stringValue: news.text },
        date_start: { timestampValue: new Date(news.date_start).toISOString() },
        date_end: { timestampValue: new Date(news.date_end).toISOString() },
        visible: { booleanValue: news.visible },
        createdAt: { timestampValue: news.createdAt || new Date().toISOString() },
      },
    }),
  });

  const result = await response.json();
  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = result;
}

// Obtener todas las noticias
export async function getAllNews(ctx: RouterContext<'/api/getAllNews'>) {
  console.log('Obteniendo todas las noticias...');

  const response = await fetch(FirestoreNewsURL, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json' },
  });

  const result = await response.json();
  if (!response.ok || result.error) {
    ctx.response.status = 500;
    ctx.response.body = { error: 'Error al obtener noticias', details: result.error };
    return;
  }

  const news = (result.documents || []).map((doc: any) => {
    const data = doc.fields;
    return {
      id: doc.name.split('/').pop(),
      ...Object.fromEntries(
        Object.entries(data).map(([key, value]) => {
          const val = Object.values(value)[0];
          return [
            key,
            key.includes('date') || key === 'createdAt' ? new Date(val) : val,
          ];
        }),
      ),
    };
  });

  ctx.response.status = 200;
  ctx.response.body = news;
}

// Eliminar noticia por ID
export async function deleteNews(ctx: RouterContext<'/api/deleteNews/:id'>) {
  const id = ctx.params.id;
  const deleteUrl = `${FirestoreNewsURL}/${id}`;

  const response = await fetch(deleteUrl, { method: 'DELETE' });

  ctx.response.status = response.ok ? 200 : 500;
  ctx.response.body = response.ok
    ? { success: true, message: 'Noticia eliminada correctamente' }
    : { error: 'Error eliminando noticia' };
}
