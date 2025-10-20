import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

type Post = {
  id: string;
  title: string;
  slug: string;
  created_at: string;
};

/**
 * BlogList loads published posts from the `posts` table and displays them as a list
 * of links. Each link navigates to a dynamic route handled by
 * `src/pages/blog/[slug].astro`. This component runs on the client only.
 */
export default function BlogList() {
  const [posts, setPosts] = useState<Post[]>([]);

  useEffect(() => {
    supabase
      .from('posts')
      .select('id, title, slug, created_at')
      .eq('published', true)
      .order('created_at', { ascending: false })
      .then(({ data }) => {
        setPosts(data ?? []);
      });
  }, []);

  return (
    <ul className="mt-4 space-y-2">
      {posts.map((p) => (
        <li key={p.id}>
          <a className="underline" href={`/blog/${p.slug}`}>
            {p.title}
          </a>{' '}
          <span className="text-sm text-gray-500">
            — {new Date(p.created_at).toLocaleDateString()}
          </span>
        </li>
      ))}
    </ul>
  );
}