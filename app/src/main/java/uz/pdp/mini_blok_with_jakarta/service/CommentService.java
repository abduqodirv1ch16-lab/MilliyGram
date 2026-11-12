package uz.pdp.mini_blok_with_jakarta.service;

import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dao.CommentDao;
import uz.pdp.mini_blok_with_jakarta.dao.CommentLikeDao;
import uz.pdp.mini_blok_with_jakarta.dto.CommentCreateDTO;
import uz.pdp.mini_blok_with_jakarta.dto.CommentResponseDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.entity.Comment;

import java.util.List;

public class CommentService {
    private final CommentDao commentDao = new CommentDao();
    private final CommentLikeDao commentLikeDao = new CommentLikeDao();
    private final AuthUserDao authUserDao = new AuthUserDao();

    public void addComment(CommentCreateDTO dto){
        Comment comment = Comment.builder()
                .postId(dto.postId())
                .userId(dto.userId())
                .content(dto.content())
                .parentId(dto.parentId())
                .build();
        commentDao.save(comment);
    }

    private final uz.pdp.mini_blok_with_jakarta.dao.FeedDao feedDao = new uz.pdp.mini_blok_with_jakarta.dao.FeedDao();

    public List<CommentResponseDTO> getMainComments(Integer postId, Integer currentUserId){
        return mapMany(commentDao.findMainComments(postId), currentUserId);
    }

    public List<CommentResponseDTO> getReplies(Integer parentCommentId,Integer currentUserId){
        return mapMany(commentDao.findReplies(parentCommentId), currentUserId);
    }

    /** Barcha izohlar uchun hisoblagichlarni bir yo'la oladi (avval har bir izohga 4 ta so'rov ketardi) */
    private List<CommentResponseDTO> mapMany(List<Comment> list, Integer currentUserId) {
        if (list.isEmpty()) return List.of();
        List<Integer> ids = list.stream().map(Comment::getId).toList();
        java.util.Set<Integer> uids = new java.util.HashSet<>();
        for (Comment c : list) uids.add(c.getUserId());
        var likes = feedDao.commentLikeCounts(ids);
        var replies = feedDao.replyCounts(ids);
        var liked = feedDao.commentsLikedBy(currentUserId, ids);
        var users = feedDao.users(uids);
        return list.stream().map(c -> {
            AuthUser u = users.get(c.getUserId());
            return new CommentResponseDTO(c.getId(), c.getContent(), c.getUserId(),
                    u != null ? u.getUsername() : "Noma'lum", u != null ? u.getAvatarUrl() : null,
                    c.getPostId(), c.getParentId(), likes.getOrDefault(c.getId(), 0L), replies.getOrDefault(c.getId(), 0L),
                    liked.contains(c.getId()), c.getCreatedAt());
        }).toList();
    }

    public boolean togleCommentLike(Integer userId, Integer commentId){
        return commentLikeDao.toggleLike(userId,commentId);
    }

    private CommentResponseDTO toDto(Comment comment,Integer currentUserId){
        long likes = commentLikeDao.countLikes(comment.getId());
        long replies = commentDao.countReplayComments(comment.getId());
        boolean isLiked = currentUserId !=null && commentLikeDao.isUserLiked(currentUserId,comment.getId());
        AuthUser user = authUserDao.findById(comment.getUserId()).orElse(null);

        return new CommentResponseDTO(
                comment.getId(),
                comment.getContent(),
                comment.getUserId(),
                user !=null ? user.getUsername() : "Noma'lum",
                user !=null ? user.getAvatarUrl() : null,
                comment.getPostId(),
                comment.getParentId(),
                likes,
                replies,
                isLiked,
                comment.getCreatedAt()
        );
    }
}
