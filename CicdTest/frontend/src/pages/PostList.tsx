import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

interface Post {
  id: number;
  title: string;
  authorName: string;
  viewCount: number;
  createdAt: string;
}

interface PostListResponse {
  content: Post[];
  totalPages: number;
  totalElements: number;
  number: number;
  size: number;
}

const PostList: React.FC = () => {
  const [posts, setPosts] = useState<Post[]>([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalPages, setTotalPages] = useState(0);
  const [searchKeyword, setSearchKeyword] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchPosts = async (page: number, keyword?: string) => {
    try {
      setLoading(true);
      const url = keyword 
        ? `/api/posts/search?keyword=${encodeURIComponent(keyword)}&page=${page}&size=10`
        : `/api/posts?page=${page}&size=10`;
      
      const response = await axios.get<PostListResponse>(url);
      setPosts(response.data.content);
      setTotalPages(response.data.totalPages);
    } catch (error) {
      console.error('Failed to fetch posts:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchPosts(currentPage, searchKeyword);
  }, [currentPage, searchKeyword]);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    setCurrentPage(0);
  };

  const handlePageChange = (page: number) => {
    setCurrentPage(page);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ko-KR');
  };

  if (loading) {
    return <div className="main-content">로딩 중...</div>;
  }

  return (
    <div className="main-content">
      <div className="card">
        <h2>게시글 목록</h2>
        
        <form onSubmit={handleSearch} className="search-box">
          <input
            type="text"
            placeholder="검색어를 입력하세요..."
            value={searchKeyword}
            onChange={(e) => setSearchKeyword(e.target.value)}
          />
          <button type="submit" className="btn btn-primary" style={{ marginLeft: '10px' }}>
            검색
          </button>
        </form>

        <ul className="post-list">
          {posts.map((post) => (
            <li key={post.id} className="post-item">
              <Link to={`/posts/${post.id}`} className="post-title">
                {post.title}
              </Link>
              <div className="post-meta">
                작성자: {post.authorName} | 
                조회수: {post.viewCount} | 
                작성일: {formatDate(post.createdAt)}
              </div>
            </li>
          ))}
        </ul>

        {totalPages > 1 && (
          <div className="pagination">
            <button
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 0}
            >
              이전
            </button>
            {Array.from({ length: totalPages }, (_, i) => (
              <button
                key={i}
                onClick={() => handlePageChange(i)}
                className={currentPage === i ? 'active' : ''}
              >
                {i + 1}
              </button>
            ))}
            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages - 1}
            >
              다음
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default PostList; 