package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.SavedPost;

import java.util.List;

public class SavedPostDao extends BaseDao{
    public boolean toggleSave(Integer userId, Integer postId){
        return execute(em->{
            em.getTransaction().begin();
            List<SavedPost> saved = em.createQuery(
                    "select sp from SavedPost sp where sp.userId =:userId and sp.postId =: postId",SavedPost.class)
                    .setParameter("userId",userId)
                    .setParameter("postId",postId)
                    .getResultList();
            boolean isSaved;
            if(saved.isEmpty()){
                SavedPost newSaved = SavedPost.builder().userId(userId).postId(postId).build();
                em.persist(newSaved);
                isSaved = true;
            }else {
                em.remove(saved.get(0));
                isSaved = false;
            }
            em.getTransaction().commit();
            return isSaved;
        });
    }

    public boolean isUserSaved(Integer userId, Integer postId){
        return execute(em->{
            Long count = em.createQuery(
                    "select count (sp) from SavedPost sp where sp.userId=:userId and  sp.postId =:postId", Long.class)
                    .setParameter("userId",userId)
                    .setParameter("postId",postId)
                    .getSingleResult();
            return count>0;
        });
    }

    public long countSaved(Integer postId){
        return execute(em->em.createQuery(
                "select count(sp) from SavedPost  sp where sp.postId=:postId", Long.class)
                .setParameter("postId",postId)
                .getSingleResult());
    }
}
