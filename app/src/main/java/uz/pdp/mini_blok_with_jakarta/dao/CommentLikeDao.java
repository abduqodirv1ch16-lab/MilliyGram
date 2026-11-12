package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.CommentLike;

import java.util.List;

public class CommentLikeDao extends BaseDao{
    public boolean toggleLike(Integer userId, Integer commentId){
        return execute(em->{
            em.getTransaction().begin();
            List<CommentLike> likes = em.createQuery(
                    "select cl from CommentLike cl where  cl.userId =:userId and cl.commentId=:commentId",CommentLike.class)
                    .setParameter("userId",userId)
                    .setParameter("commentId",commentId)
                    .getResultList();
            boolean isLiked;
            if(likes.isEmpty()){
                em.persist(CommentLike.builder().userId(userId).commentId(commentId).build());
                isLiked=true;
            }else {
                em.remove(likes.get(0));
                isLiked=false;
            }
            em.getTransaction().commit();
            return isLiked;
        });
    }
    public long countLikes(Integer commentId){
        return execute(em->em.createQuery(
                "select count (cl) from CommentLike cl where cl.commentId =: commentId", Long.class)
                .setParameter("commentId",commentId)
                .getSingleResult());
    }

    public boolean isUserLiked (Integer userId, Integer commentId){
        return execute(em->{
            Long count= em.createQuery(
                    "select count(cl) from CommentLike cl where cl.userId=:userId and cl.commentId=:commentId", Long.class)
                    .setParameter("userId",userId)
                    .setParameter("commentId",commentId)
                    .getSingleResult();
            return count >0;
        });
    }
}
