package com.parking.exception;

import com.parking.model.dto.ResultDTO;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.WebRequest;

import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class GlobalExceptionHandler {
    
    /**
     * 处理自定义业务异常
     */
    @ExceptionHandler(ParkingException.class)
    @ResponseBody
    public ResponseEntity<ResultDTO> handleParkingException(ParkingException ex, WebRequest request) {
        ResultDTO result = ResultDTO.fail(ex.getMessage());
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }
    
    /**
     * 处理参数验证异常
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseBody
    public ResponseEntity<ResultDTO> handleValidationException(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> {
            errors.put(error.getField(), error.getDefaultMessage());
        });
        
        String errorMessage = "参数验证失败：" + errors.toString();
        ResultDTO result = ResultDTO.fail(errorMessage);
        return new ResponseEntity<>(result, HttpStatus.BAD_REQUEST);
    }
    
    /**
     * 处理其他所有未捕获的异常
     */
    @ExceptionHandler(Exception.class)
    @ResponseBody
    public ResponseEntity<ResultDTO> handleAllExceptions(Exception ex, WebRequest request) {
        // 记录异常日志
        ex.printStackTrace();
        
        ResultDTO result = ResultDTO.fail("系统异常，请稍后重试");
        return new ResponseEntity<>(result, HttpStatus.INTERNAL_SERVER_ERROR);
    }
}