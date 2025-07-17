import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';

interface Post {
  id: number;
  title: string;
  content: string;
  authorName: string;
  viewCount: number;
  createdAt: string;
  updatedAt: string;
}

const PostDetail: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [post, setPost] = useState<Post | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  
  const { user } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchPost = async () => {
      try {
        setLoading(true);
        const response = await axios.get<Post>(`/api/posts/${id}`);
        setPost(response.data);
      } catch (error) {
        setError('게시글을 불러올 수 없습니다.');
        console.error('Failed to fetch post:', error);
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchPost();
    }
  }, [id]);

  const handleDelete = async () => {
    if (!window.confirm('정말로 이 게시글을 삭제하시겠습니까?')) {
      return;
    }

    try {
      await axios.delete(`/api/posts/${id}`);
      navigate('/posts');
    } catch (error: any) {
      alert(error.response?.data?.error || '삭제에 실패했습니다.');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleString('ko-KR');
  };

  if (loading) {
    return <div className="main-content">로딩 중...</div>;
  }

  if (error || !post) {
    return <div className="main-content">{error}</div>;
  }

  const isAuthor = user?.username === post.authorName;

  return (
    <div className="main-content">
      <div className="card">
        <h2>{post.title}</h2>
        <div className="post-meta" style={{ marginBottom: '20px' }}>
          작성자: {post.authorName} | 
          조회수: {post.viewCount} | 
          작성일: {formatDate(post.createdAt)}
          {post.updatedAt !== post.createdAt && (
            <> | 수정일: {formatDate(post.updatedAt)}</>
          )}
        </div>
        
        <div style={{ 
          border: '1px solid #eee', 
          padding: '20px', 
          borderRadius: '4px',
          marginBottom: '20px',
          whiteSpace: 'pre-wrap'
        }}>
          {post.content}
        </div>

        <div>
          <Link to="/posts" className="btn btn-primary" style={{ marginRight: '10px' }}>
            목록으로
          </Link>
          {isAuthor && (
            <>
              <Link to={`/posts/${id}/edit`} className="btn btn-primary" style={{ marginRight: '10px' }}>
                수정
              </Link>
              <button onClick={handleDelete} className="btn btn-danger">
                삭제
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default PostDetail; 