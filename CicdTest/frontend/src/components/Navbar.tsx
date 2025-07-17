import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

const Navbar: React.FC = () => {
  const { user, isAuthenticated, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <nav className="navbar">
      <div className="container">
        <Link to="/" style={{ fontSize: '20px', fontWeight: 'bold' }}>
          게시판 앱
        </Link>
        <div>
          <Link to="/posts">게시글 목록</Link>
          {isAuthenticated ? (
            <>
              <Link to="/posts/new">글쓰기</Link>
              <span style={{ marginLeft: '20px' }}>
                안녕하세요, {user?.username}님!
              </span>
              <button 
                onClick={handleLogout}
                style={{ 
                  marginLeft: '20px', 
                  background: 'none', 
                  border: 'none', 
                  color: 'white', 
                  cursor: 'pointer' 
                }}
              >
                로그아웃
              </button>
            </>
          ) : (
            <>
              <Link to="/login">로그인</Link>
              <Link to="/signup">회원가입</Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
};

export default Navbar; 