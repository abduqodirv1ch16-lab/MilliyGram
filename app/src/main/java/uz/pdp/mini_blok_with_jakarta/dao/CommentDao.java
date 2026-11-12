package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.Comment;

import java.util.List;

public class CommentDao extends BaseDao{
    public void save(Comment comment){
        executeInTransaction(em->em.persist(comment));
    }

    public List<Comment> findMainComments(Integer postId){
        return execute(em->em.createQuery(
                "select c from Comment c where c.postId =:postId and c.parentId is null order by c.createdAt asc", Comment.class)
                        .setParameter("postId",postId)
                        .getResultList());
    }

    public List<Comment> findReplies(Integer parentCommentId){
        return execute(em->em.createQuery(
                "select c from Comment c where c.parentId=:parentId order by c.createdAt asc", Comment.class)
                .setParameter("parentId",parentCommentId)
                .getResultList());
    }

    public long countComments(Integer postId){
        return execute(em->em.createQuery(
                        "select count(c) from Comment c where c.postId=:postId", Long.class)
                .setParameter("postId",postId)
                .getSingleResult());
    }


    public long countReplayComments(Integer parentCommentId){
        return execute(em->em.createQuery(
                        "select count(c) from Comment c where c.parentId=:parentCommentId", Long.class)
                .setParameter("parentCommentId",parentCommentId)
                .getSingleResult());
    }
}
