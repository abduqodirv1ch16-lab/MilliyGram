package uz.pdp.mini_blok_with_jakarta.service;

import uz.pdp.mini_blok_with_jakarta.dao.*;
import uz.pdp.mini_blok_with_jakarta.dto.PostCreateDTO;
import uz.pdp.mini_blok_with_jakarta.dto.PostDetailResponseDTO;
import uz.pdp.mini_blok_with_jakarta.dto.PostUpdateDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.entity.Post;

import java.util.*;

public class PostService {
    private final PostDao postDao = new PostDao();
    private final PostLikeDao postLikeDao = new PostLikeDao();
    private final SavedPostDao savedPostDao = new SavedPostDao();
    private final CommentDao commentDao = new CommentDao();
    private final AuthUserDao authUserDao = new AuthUserDao();


    public void createPost(PostCreateDTO dto) {
       Post post = Post.builder()
               .title(dto.title())
               .content(dto.content())
               .mediaURL(dto.mediaUrl())
               .mediaType(dto.mediaType())
               .userId(dto.userId())
               .viewCount(0L)
               .build();
       postDao.save(post);
    }
    public boolean updatePost(PostUpdateDTO dto){
        Optional<Post> optional = postDao.findId(dto.id());
        if(optional.isEmpty()) return false;
        Post post = optional.get();
        if(!post.getUserId().equals(dto.userId())){
            return false;
        }
        post.setTitle(dto.title());
        post.setContent(dto.content());
        postDao.update(post);
        return true;
    }

    public boolean deletePost(Integer postId, Integer currentUser){
        Optional<Post> opPost = postDao.findId(postId);
        if(opPost.isEmpty()) return false;
        Post post = opPost.get();
        if(!post.getUserId().equals(currentUser)){
            return false;
        }
        String media = new AdminDao().deletePost(postId);   // izoh, like va saqlashlar bilan birga
        if (media != null) {
            java.io.File f = uz.pdp.mini_blok_with_jakarta.utils.FileUtils.resolveSafe(media);
            if (f != null) f.delete();
        }
        return true;
    }
    private final FeedDao feedDao = new FeedDao();

    /** Bosh sahifa: eng yangi postlar, sahifalab (beforeId — oldingi sahifadagi oxirgi post) */
    public List<PostDetailResponseDTO> getFeed(Integer currentUserId, Integer beforeId, int limit) {
        return mapMany(feedDao.feed(beforeId, limit), currentUserId);
    }

    /** Eski chaqiruvlar uchun: oxirgi 30 ta post */
    public List<PostDetailResponseDTO> getFeedPosts(Integer currentUserid){
        return getFeed(currentUserid, null, 30);
    }

    public List<PostDetailResponseDTO> getUserPosts(Integer userId, Integer currentUserId) {
        return mapMany(feedDao.byUser(userId), currentUserId);
    }

    public List<PostDetailResponseDTO> getSavedPosts(Integer currentUserId) {
        return mapMany(feedDao.savedBy(currentUserId), currentUserId);
    }

    public List<PostDetailResponseDTO> getTrending(Integer currentUserId, String tag, int limit) {
        List<Post> posts = feedDao.trending(7, tag, limit);
        if (posts.size() < 6) posts = feedDao.trending(tag == null ? 60 : 365, tag, limit);   // yangi saytda — kengroq oraliq
        return mapMany(posts, currentUserId);
    }

    public PostDetailResponseDTO getPostById(Integer postId, Integer currentUserId){
        postDao.incrementViewCount(postId);
        return postDao.findId(postId)
                .map(post -> mapToDetailDto(post,currentUserId))
                .orElse(null);
    }

    public PostDetailResponseDTO mapToDetailDto(Post post, Integer currentUserId){
        return mapMany(List.of(post), currentUserId).get(0);
    }

    /** Ko'p postni bir yo'la DTO ga aylantiradi: jami 6 ta so'rov (post sonidan qat'i nazar). */
    public List<PostDetailResponseDTO> mapMany(List<Post> posts, Integer currentUserId) {
        if (posts.isEmpty()) return Collections.emptyList();
        List<Integer> ids = posts.stream().map(Post::getId).toList();
        Set<Integer> authorIds = new HashSet<>();
        for (Post p : posts) authorIds.add(p.getUserId());
        Map<Integer, Long> likes = feedDao.likeCounts(ids), comments = feedDao.commentCounts(ids), saves = feedDao.saveCounts(ids);
        Set<Integer> liked = feedDao.likedBy(currentUserId, ids), saved = feedDao.savedBy(currentUserId, ids);
        Map<Integer, AuthUser> authors = feedDao.users(authorIds);
        List<PostDetailResponseDTO> out = new ArrayList<>(posts.size());
        for (Post post : posts) {
            AuthUser a = authors.get(post.getUserId());
            out.add(new PostDetailResponseDTO(
                    post.getId(), post.getTitle(), post.getContent(), post.getMediaURL(), post.getMediaType(), post.getViewCount(),
                    likes.getOrDefault(post.getId(), 0L), comments.getOrDefault(post.getId(), 0L), saves.getOrDefault(post.getId(), 0L),
                    liked.contains(post.getId()), saved.contains(post.getId()), post.getUserId(),
                    a != null ? a.getUsername() : "Noma'lum", a != null ? a.getAvatarUrl() : null,
                    post.getCreatedAt(), a != null && a.isVerifiedUser()));
        }
        return out;
    }
}
