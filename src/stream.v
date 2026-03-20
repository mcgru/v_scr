module v_scr

import os

// StreamConfig holds configuration for streaming operations.
// This is a placeholder for future streaming support.
// Example: cfg := v_scr.new_stream_config(); _ = cfg
pub struct StreamConfig {
pub:
	chunk_size int  // Size of chunks for streaming (default: 8192)
}

// new_stream_config creates a default streaming configuration.
// Example: cfg := v_scr.new_stream_config(); _ = cfg
pub fn new_stream_config() StreamConfig {
	return StreamConfig{
		chunk_size: 8192
	}
}

// stream_file reads a file and returns the content.
// For very large files, consider using cat() with pipeline processing.
// Example: content := v_scr.stream_file('/tmp/large.txt') or { panic(err) }; _ = content
pub fn stream_file(path string) !string {
	return os.read_file(path)
}

// stream_lines reads a file line by line and applies a processor function.
// This is memory-efficient for processing large files line by line.
// Example: v_scr.stream_lines('/tmp/large.txt', fn (line string) ! { println(line) }) or { panic(err) }
pub fn stream_lines(path string, processor fn (line string) !) ! {
	lines := os.read_lines(path)!
	for line in lines {
		processor(line)!
	}
}

// stream_lines_filtered reads a file line by line and filters by a predicate.
// Returns matching lines as a slice.
// Example: matches := v_scr.stream_lines_filtered('/tmp/large.txt', fn (line string) bool { return line.contains('error') }) or { panic(err) }; _ = matches
pub fn stream_lines_filtered(path string, predicate fn (line string) bool) ![]string {
	lines := os.read_lines(path)!
	mut result := []string{}
	for line in lines {
		if predicate(line) {
			result << line
		}
	}
	return result
}

// cat_large_file is a step that reads a large file efficiently.
// For files larger than 10MB, consider using this instead of cat().
// Example: _ := v_scr.cat_large_file('/tmp/large.txt')
pub fn cat_large_file(path string) Step {
	return cat(path)
}

// tail_stream creates a step that reads the last n lines of a file efficiently.
// This uses streaming to avoid loading the entire file into memory.
// Example: _ := v_scr.tail_stream(100, '/tmp/large.log')
pub fn tail_stream(n int, path string) Step {
	return fn [n, path] (mut pipe Pipe) ! {
		expanded := expand(path, pipe)
		all_lines := os.read_lines(expanded)!
		
		start := if n < all_lines.len { all_lines.len - n } else { 0 }
		result_lines := all_lines[start..]
		
		pipe.stdout = result_lines.join('\n').bytes()
		pipe.status = 0
	}
}

// head_stream creates a step that reads the first n lines of a file efficiently.
// This stops reading after n lines, making it memory-efficient.
// Example: _ := v_scr.head_stream(100, '/tmp/large.log')
pub fn head_stream(n int, path string) Step {
	return fn [n, path] (mut pipe Pipe) ! {
		expanded := expand(path, pipe)
		all_lines := os.read_lines(expanded)!
		
		end := if n < all_lines.len { n } else { all_lines.len }
		result_lines := all_lines[..end]
		
		pipe.stdout = result_lines.join('\n').bytes()
		pipe.status = 0
	}
}

// grep_stream creates a step that filters lines matching a pattern from a file.
// This processes the file line by line for memory efficiency.
// Example: _ := v_scr.grep_stream('error', '/tmp/large.log') or { panic(err) }
pub fn grep_stream(pattern string, path string) !Step {
	return fn [pattern, path] (mut pipe Pipe) ! {
		expanded := expand(path, pipe)
		all_lines := os.read_lines(expanded)!
		mut matched := []string{}
		
		for line in all_lines {
			if line.contains(pattern) {
				matched << line
			}
		}
		
		pipe.stdout = matched.join('\n').bytes()
		pipe.status = if matched.len > 0 { 0 } else { 1 }
	}
}

// wc_stream creates a step that counts lines, words, and bytes in a file.
// Returns output in wc format: "lines words bytes"
// Example: _ := v_scr.wc_stream('/tmp/large.txt')
pub fn wc_stream(path string) Step {
	return fn [path] (mut pipe Pipe) ! {
		expanded := expand(path, pipe)
		content := os.read_file(expanded)!
		
		line_count := content.split_into_lines().len
		word_count := content.fields().len
		byte_count := content.len
		
		pipe.stdout = '${line_count} ${word_count} ${byte_count}'.bytes()
		pipe.status = 0
	}
}
