package com.example.demo.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;

public class PostDto {
    
    @Data
    public static class CreateRequest {
        @NotBlank(message = "제목은 필수입니다")
        private String title;
        
        @NotBlank(message = "내용은 필수입니다")
        private String content;
    }
    
    @Data
    public static class UpdateRequest {
        @NotBlank(message = "제목은 필수입니다")
        private String title;
        
        @NotBlank(message = "내용은 필수입니다")
        private String content;
    }
    
    @Data
    public static class PostResponse {
        private Long id;
        private String title;
        private String content;
        private String authorName;
        private Integer viewCount;
        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;
    }
    
    @Data
    public static class PostListResponse {
        private Long id;
        private String title;
        private String authorName;
        private Integer viewCount;
        private LocalDateTime createdAt;
    }
} 