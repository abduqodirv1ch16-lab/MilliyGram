package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.Follow;

import java.util.List;

public class FollowDao extends BaseDao{
    public boolean toggleFollow(Integer followerId, Integer followingId){
        return execute(em->{
            em.getTransaction().begin();
            List<Follow> follows  = em.createQuery(
                            "select f from Follow f where f.followerId=:followerId and f.followingId=:followingId", Follow.class)
                    .setParameter("followerId",followerId)
                    .setParameter("followingId",followingId)
                    .getResultList();
            boolean isFollowing;
            if(follows.isEmpty()){
                em.persist(Follow.builder().followerId(followerId).followingId(followingId).build());
                isFollowing = true;
            }else {
                em.remove(follows.get(0));
                isFollowing=false;
            }
            em.getTransaction().commit();
            return isFollowing;
        });
    }

    // Bu foydalanuvchiga obuna bo'lganlar (Kimlar buni kuzatyapti)
    public long countFollowers(Integer userId){
        return execute(em->em.createQuery(
                        "select count (f) from Follow f where f.followingId = :userId", Long.class)
                .setParameter("userId", userId)
                .getSingleResult());
    }

    // Bu foydalanuvchi obuna bo'lganlar (Kimlarni kuzatmoqda)
    public long countFollowing(Integer userId) {
        return execute(em -> em.createQuery(
                        "select count(f) from Follow f where f.followerId = :userId", Long.class)
                .setParameter("userId", userId)
                .getSingleResult());
    }

    public boolean isFollowing(Integer followerId, Integer followingId) {
        return execute(em -> {
            Long count = em.createQuery(
                            "select count(f) from Follow f where f.followerId = :followerId and f.followingId = :followingId", Long.class)
                    .setParameter("followerId", followerId)
                    .setParameter("followingId", followingId)
                    .getSingleResult();
            return count > 0;
        });
    }
}