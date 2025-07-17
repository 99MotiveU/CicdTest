import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import axios from 'axios';

const PostForm: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();
  const isEdit = !!id;

  useEffect(() => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }

    if (isEdit) {
      fetchPost();
    }
  }, [id, isAuthenticated, navigate]);

  const fetchPost = async () => {
    try {
      const response = await axios.get(`/api/posts/${id}`);
      const post = response.data;
      setTitle(post.title);
      setContent(post.content);
    } catch (error) {
      setError('게시글을 불러올 수 없습니다.');
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (isEdit) {
        await axios.put(`/api/posts/${id}`, { title, content });
      } else {
        await axios.post('/api/posts', { title, content });
      }
      navigate('/posts');
    } catch (error: any) {
      setError(error.response?.data?.error || '저장에 실패했습니다.');
    } finally {
      setLoading(false);
    }
  };

  if (!isAuthenticated) {
    return null;
  }

  return (
    <div className="main-content">
      <div className="card">
        <h2>{isEdit ? '게시글 수정' : '새 게시글 작성'}</h2>
        {error && <div className="error-message">{error}</div>}
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="title">제목</label>
            <input
              type="text"
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="content">내용</label>
            <textarea
              id="content"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? '저장 중...' : (isEdit ? '수정' : '작성')}
          </button>
        </form>
      </div>
    </div>
  );
};

export default PostForm; 