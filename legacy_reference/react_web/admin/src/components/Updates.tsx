import React, { useEffect, useState } from 'react';
import { collection, query, where, orderBy, onSnapshot, doc, getDocs, limit } from 'firebase/firestore';
import { db } from '../firebase';
import { Post } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { Calendar, User, ChevronRight, ArrowLeft, Share2, Bell, Clock } from 'lucide-react';
import { Helmet } from 'react-helmet-async';
import { format } from 'date-fns';
import { useParams, useNavigate } from 'react-router-dom';
import { getDomainFriendlyOrigin, shareContent } from '../utils/shareUtils';

const Updates = ({ setHeaderAction }: { setHeaderAction?: (action: React.ReactNode) => void }) => {
  const { slug } = useParams<{ slug: string }>();
  const navigate = useNavigate();
  const [posts, setPosts] = useState<Post[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedPost, setSelectedPost] = useState<Post | null>(null);

  useEffect(() => {
    const q = query(
      collection(db, 'posts'),
      where('isActive', '==', true),
      orderBy('createdAt', 'desc')
    );

    const unsubscribe = onSnapshot(q, (snapshot) => {
      const fetchedPosts = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as Post[];
      setPosts(fetchedPosts);
      setLoading(false);

      if (slug) {
        const post = fetchedPosts.find(p => p.slug === slug);
        if (post) {
          setSelectedPost(post);
        }
      }
    });

    return () => unsubscribe();
  }, [slug]);

  useEffect(() => {
    if (!setHeaderAction) return;

    if (slug) {
      setHeaderAction(
        <button 
          onClick={() => navigate('/updates')}
          className="p-2 -ml-2 text-white hover:bg-white/10 rounded-lg transition-colors flex items-center justify-center"
          title="Back to Updates"
        >
          <ArrowLeft size={20} strokeWidth={2.5} />
        </button>
      );
    } else {
      setHeaderAction(null);
    }

    return () => setHeaderAction(null);
  }, [slug, setHeaderAction, navigate]);

  const handleShare = async (post: Post) => {
    const shareUrl = `${getDomainFriendlyOrigin()}/updates/${post.slug}`;
    await shareContent({
      title: post.title,
      text: post.excerpt,
      url: shareUrl,
    });
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
          className="w-10 h-10 border-4 border-emerald-500 border-t-transparent rounded-full"
        />
      </div>
    );
  }

  if (slug && selectedPost) {
    return (
      <div className="max-w-7xl mx-auto pb-8">
        <Helmet>
          <title>{selectedPost.metaTitle || selectedPost.title} | Rankearn Updates</title>
          <meta name="description" content={selectedPost.metaDescription || selectedPost.excerpt} />
        </Helmet>

        <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 overflow-hidden flex flex-col min-h-[650px]">
          <div className="p-4 lg:p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row items-start lg:items-center lg:justify-between gap-4 lg:gap-6 text-left">
            <div className="flex items-center gap-3 lg:gap-4">
              <div className="p-2.5 lg:p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
                <Bell size={20} className="lg:w-6 lg:h-6" strokeWidth={3} />
              </div>
              <div>
                <h3 className="text-lg lg:text-xl font-black text-slate-900 leading-none">News Update</h3>
                <p className="text-[10px] lg:text-[12px] text-slate-400 font-bold mt-1 flex items-center justify-start gap-2">
                  Official Announcements
                </p>
              </div>
            </div>
          </div>

          <div className="p-4 lg:p-8 flex-1">
            <article className="w-full">
              {selectedPost.imageUrl && (
                <img
                  src={selectedPost.imageUrl}
                  alt={selectedPost.title}
                  className="w-full aspect-video object-cover rounded-2xl mb-8 shadow-xl shadow-slate-900/5 border border-slate-100"
                />
              )}
              
              <div className="flex flex-wrap items-center gap-3 mb-6">
                <div className="flex items-center gap-2 text-[10px] font-black text-emerald-600 bg-emerald-50 px-3 py-1 rounded-full uppercase tracking-wider border border-emerald-100">
                  <Bell size={10} strokeWidth={3} />
                  <span>{selectedPost.category || 'Update'}</span>
                </div>
                <div className="flex items-center gap-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">
                  <Calendar size={12} strokeWidth={3} className="text-emerald-500" />
                  <span>
                    {selectedPost.createdAt?.seconds 
                      ? format(new Date(selectedPost.createdAt.seconds * 1000), 'dd MMM yyyy')
                      : 'Recent'}
                  </span>
                </div>
              </div>

              <h1 className="text-2xl lg:text-4xl font-black text-slate-900 leading-tight mb-8">
                {selectedPost.title}
              </h1>

              <div className="max-w-none text-slate-600 leading-relaxed rich-text-content" dangerouslySetInnerHTML={{ __html: selectedPost.content }} />
              
              <style>{`
                .rich-text-content { 
                  font-size: 1rem; 
                  line-height: 1.7;
                  word-break: break-word;
                  overflow-wrap: break-word;
                }
                @media (min-width: 1024px) {
                  .rich-text-content { font-size: 1.1rem; }
                }
                .rich-text-content p { 
                  margin-bottom: 1.25rem; 
                  word-break: break-word;
                }
                .rich-text-content h1, .rich-text-content h2, .rich-text-content h3 { 
                  font-weight: 900; 
                  color: #0f172a; 
                  margin-top: 2rem; 
                  margin-bottom: 1rem;
                  line-height: 1.3;
                  word-break: break-word;
                }
                .rich-text-content img { 
                  max-width: 100%; 
                  height: auto; 
                  border-radius: 0.75rem; 
                  margin: 1.5rem 0; 
                }
                .rich-text-content ul, .rich-text-content ol { 
                  padding-left: 1.25rem; 
                  margin-bottom: 1.25rem; 
                }
                .rich-text-content li { margin-bottom: 0.5rem; }
                .rich-text-content a { color: #10b981; font-weight: 700; text-decoration: underline; }
                .rich-text-content * { max-width: 100% !important; }
              `}</style>
              
              <footer className="mt-12 pt-8 border-t border-slate-100 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-400">
                    <User size={20} />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-slate-900">{selectedPost.authorName || 'Rankearn Team'}</p>
                    <p className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Official Author</p>
                  </div>
                </div>
                <button
                  onClick={() => handleShare(selectedPost)}
                  className="flex items-center gap-2 px-6 py-2.5 rounded-lg bg-emerald-500 text-white hover:bg-emerald-600 transition-all font-bold text-sm shadow-lg shadow-emerald-900/20 active:scale-95"
                >
                  <Share2 size={16} />
                  <span>Share</span>
                </button>
              </footer>
            </article>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto pb-8">
      <Helmet>
        <title>Updates & News | Rankearn</title>
        <meta name="description" content="Stay updated with the latest news, exam tips, and announcements from Rankearn." />
      </Helmet>

      <div className="bg-white rounded-xl border border-slate-200 shadow-lg shadow-slate-900/5 overflow-hidden flex flex-col min-h-[650px]">
        <div className="p-4 lg:p-6 border-b border-slate-50 bg-slate-50/30 flex flex-col lg:flex-row items-start lg:items-center lg:justify-between gap-4 lg:gap-6 text-left">
          <div className="flex items-center gap-3 lg:gap-4">
            <div className="p-2.5 lg:p-3 bg-emerald-500 text-white rounded-lg shadow-md shadow-emerald-900/20">
              <Bell size={20} className="lg:w-6 lg:h-6" strokeWidth={3} />
            </div>
            <div>
              <h3 className="text-lg lg:text-xl font-black text-slate-900 leading-none">Latest Updates</h3>
              <p className="text-[10px] lg:text-[12px] text-slate-400 font-bold mt-1 flex items-center justify-start gap-2">
                Stay informed with platform news
              </p>
            </div>
          </div>
        </div>

        <div className="p-4 lg:p-8 flex-1">
          {posts.length === 0 ? (
            <div className="flex-1 flex flex-col items-center justify-center py-20">
              <div className="w-16 h-16 bg-slate-50 rounded-2xl flex items-center justify-center text-slate-200 mb-4 border border-dashed border-slate-200">
                <Bell size={32} />
              </div>
              <h4 className="text-sm font-black text-slate-900 uppercase tracking-tight">Silent for now</h4>
              <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest mt-2">No new announcements.</p>
            </div>
          ) : (
            <div className="flex flex-col gap-6 w-full max-w-none">
              <AnimatePresence>
                {posts.map((post, index) => (
                  <motion.div
                    key={post.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.1 }}
                    onClick={() => navigate(`/updates/${post.slug}`)}
                    className="flex items-stretch gap-4 p-3 rounded-2xl border border-slate-100 hover:border-emerald-500/20 hover:bg-emerald-50/10 transition-all cursor-pointer group bg-white shadow-sm hover:shadow-md"
                  >
                    <div className="w-24 sm:w-32 h-24 sm:h-32 shrink-0 rounded-xl overflow-hidden shadow-inner bg-slate-50">
                      {post.imageUrl ? (
                        <img
                          src={post.imageUrl}
                          alt={post.title}
                          className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
                        />
                      ) : (
                        <div className="w-full h-full flex items-center justify-center text-slate-200">
                          <Bell size={24} />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 flex flex-col justify-center min-w-0">
                      <div className="flex items-center gap-2 text-[9px] font-black text-emerald-600 uppercase tracking-widest mb-1.5">
                        <span className="bg-emerald-50 px-2 py-0.5 rounded">
                          {post.category || 'Update'}
                        </span>
                        <span className="text-slate-300">•</span>
                        <span>
                          {post.createdAt?.seconds 
                            ? format(new Date(post.createdAt.seconds * 1000), 'dd MMM')
                            : 'Recent'}
                        </span>
                      </div>
                      <h3 className="text-sm sm:text-base font-black text-slate-900 mb-1.5 line-clamp-2 leading-tight group-hover:text-emerald-600 transition-colors">
                        {post.title}
                      </h3>
                      <p className="text-[11px] text-slate-400 font-bold line-clamp-2 leading-relaxed">
                        {post.excerpt}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </AnimatePresence>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Updates;
