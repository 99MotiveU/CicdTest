package com.example.demo.service;

import com.example.demo.dto.PostDto;
import com.example.demo.entity.Post;
import com.example.demo.entity.User;
import com.example.demo.repository.PostRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
public class PostService {
    
    private final PostRepository postRepository;
    private final UserService userService;
    
    public PostService(PostRepository postRepository, UserService userService) {
        this.postRepository = postRepository;
        this.userService = userService;
    }
    
    public Page<PostDto.PostListResponse> getAllPosts(Pageable pageable) {
        return postRepository.findAllByOrderByCreatedAtDesc(pageable)
                .map(this::convertToPostListResponse);
    }
    
    public Page<PostDto.PostListResponse> searchPosts(String keyword, Pageable pageable) {
        return postRepository.findByTitleContainingOrContentContaining(keyword, pageable)
                .map(this::convertToPostListResponse);
    }
    
    public PostDto.PostResponse getPostById(Long id) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글을 찾을 수 없습니다"));
        
        // 조회수 증가
        post.setViewCount(post.getViewCount() + 1);
        postRepository.save(post);
        
        return convertToPostResponse(post);
    }
    
    public PostDto.PostResponse createPost(PostDto.CreateRequest request, String username) {
        User user = (User) userService.loadUserByUsername(username);
        
        Post post = new Post();
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setAuthor(user);
        
        Post savedPost = postRepository.save(post);
        return convertToPostResponse(savedPost);
    }
    
    public PostDto.PostResponse updatePost(Long id, PostDto.UpdateRequest request, String username) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글을 찾을 수 없습니다"));
        
        User user = (User) userService.loadUserByUsername(username);
        if (!post.getAuthor().getId().equals(user.getId())) {
            throw new RuntimeException("게시글을 수정할 권한이 없습니다");
        }
        
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        
        Post updatedPost = postRepository.save(post);
        return convertToPostResponse(updatedPost);
    }
    
    public void deletePost(Long id, String username) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글을 찾을 수 없습니다"));
        
        User user = (User) userService.loadUserByUsername(username);
        if (!post.getAuthor().getId().equals(user.getId())) {
            throw new RuntimeException("게시글을 삭제할 권한이 없습니다");
        }
        
        postRepository.delete(post);
    }
    
    private PostDto.PostResponse convertToPostResponse(Post post) {
        PostDto.PostResponse response = new PostDto.PostResponse();
        response.setId(post.getId());
        response.setTitle(post.getTitle());
        response.setContent(post.getContent());
        response.setAuthorName(post.getAuthor().getUsername());
        response.setViewCount(post.getViewCount());
        response.setCreatedAt(post.getCreatedAt());
        response.setUpdatedAt(post.getUpdatedAt());
        return response;
    }
    
    private PostDto.PostListResponse convertToPostListResponse(Post post) {
        PostDto.PostListResponse response = new PostDto.PostListResponse();
        response.setId(post.getId());
        response.setTitle(post.getTitle());
        response.setAuthorName(post.getAuthor().getUsername());
        response.setViewCount(post.getViewCount());
        response.setCreatedAt(post.getCreatedAt());
        return response;
    }
} 