package com.example.demo.controller;

import com.example.demo.dto.PostDto;
import com.example.demo.service.PostService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/posts")
@CrossOrigin(origins = "*")
public class PostController {
    
    private final PostService postService;
    
    public PostController(PostService postService) {
        this.postService = postService;
    }
    
    @GetMapping
    public ResponseEntity<Page<PostDto.PostListResponse>> getAllPosts(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<PostDto.PostListResponse> posts = postService.getAllPosts(pageable);
        return ResponseEntity.ok(posts);
    }
    
    @GetMapping("/search")
    public ResponseEntity<Page<PostDto.PostListResponse>> searchPosts(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<PostDto.PostListResponse> posts = postService.searchPosts(keyword, pageable);
        return ResponseEntity.ok(posts);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<PostDto.PostResponse> getPostById(@PathVariable Long id) {
        PostDto.PostResponse post = postService.getPostById(id);
        return ResponseEntity.ok(post);
    }
    
    @PostMapping
    public ResponseEntity<?> createPost(@Valid @RequestBody PostDto.CreateRequest request) {
        try {
            // 임시로 고정 사용자명 사용
            PostDto.PostResponse post = postService.createPost(request, "admin");
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<?> updatePost(@PathVariable Long id,
                                       @Valid @RequestBody PostDto.UpdateRequest request) {
        try {
            PostDto.PostResponse post = postService.updatePost(id, request, "admin");
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deletePost(@PathVariable Long id) {
        try {
            postService.deletePost(id, "admin");
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.badRequest().body(error);
        }
    }
} 