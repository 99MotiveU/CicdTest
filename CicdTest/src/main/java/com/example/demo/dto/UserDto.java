package com.example.demo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

public class UserDto {
    
    @Data
    public static class SignUpRequest {
        @NotBlank(message = "사용자명은 필수입니다")
        @Size(min = 3, max = 20, message = "사용자명은 3-20자 사이여야 합니다")
        private String username;
        
        @NotBlank(message = "비밀번호는 필수입니다")
        @Size(min = 6, message = "비밀번호는 최소 6자 이상이어야 합니다")
        private String password;
        
        @NotBlank(message = "이메일은 필수입니다")
        @Email(message = "올바른 이메일 형식이 아닙니다")
        private String email;
        
        @NotBlank(message = "이름은 필수입니다")
        private String fullName;
    }
    
    @Data
    public static class LoginRequest {
        @NotBlank(message = "사용자명은 필수입니다")
        private String username;
        
        @NotBlank(message = "비밀번호는 필수입니다")
        private String password;
    }
    
    @Data
    public static class UserResponse {
        private Long id;
        private String username;
        private String email;
        private String fullName;
        private String role;
    }
} 