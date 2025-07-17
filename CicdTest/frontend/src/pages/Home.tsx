import React from 'react';
import { Link } from 'react-router-dom';

const Home: React.FC = () => {
  return (
    <div className="main-content">
      <div className="card">
        <h1>게시판 앱에 오신 것을 환영합니다!</h1>
        <p>이 애플리케이션은 Spring Boot와 React</p>
        <p>다음 기능들을 사용할 수 있습니다:</p>
        <ul>
          <li>회원가입 및 로그인</li>
          <li>게시글 작성, 조회, 수정, 삭제</li>
          <li>게시글 검색</li>
          <li>페이지네이션</li>
        </ul>
        <div style={{ marginTop: '20px' }}>
          <Link to="/posts" className="btn btn-primary" style={{ marginRight: '10px' }}>
            게시글 목록 확인하기
          </Link>
          <Link to="/signup" className="btn btn-primary">
            회원가입
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Home; 