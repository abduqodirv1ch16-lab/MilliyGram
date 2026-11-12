package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.Post;

import java.util.List;
import java.util.Optional;

public class PostDao extends BaseDao{

    public void save(Post post){
      executeInTransaction(em->em.persist(post));
    }

    public void update(Post post){
        executeInTransaction(em->em.merge(post));
    }

    public void delete(Integer id){
        executeInTransaction(em->{
            Post post = em.find(Post.class,id);
            if(post!=null){
                em.remove(post);
            }
        });
    }

    public Optional<Post> findId(Integer id){
        return execute(em->Optional.ofNullable(em.find(Post.class,id)));
    }

    public List<Post> findAllOrdered(){
       return execute(em->em.createQuery(
               "select p from Post p order by p.createdAt desc ", Post.class)
               .getResultList());
    }

    public List<Post> findByUserId(Integer userId){
        return execute(em->em.createQuery(
                "select p from Post p where p.userId = :userId order by p.createdAt desc ",Post.class)
                .setParameter("userId",userId)
                .getResultList());
    }

    public void incrementViewCount(Integer postId){
        executeInTransaction(em->em.createQuery(
                "update Post p set p.viewCount = p.viewCount+1 where p.id =:postId")
                .setParameter("postId",postId)
                .executeUpdate());
    }
}
