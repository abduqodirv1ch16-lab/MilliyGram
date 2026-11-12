package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;

import java.util.List;
import java.util.Optional;


public class AuthUserDao  extends BaseDao{
      public  void save(AuthUser authUser){
        executeInTransaction(em->em.persist(authUser));
      }

      public void update(AuthUser authUser){
          executeInTransaction(em->em.merge(authUser));
      }

      public Optional<AuthUser> findById (Integer id){
          return execute(em->Optional.ofNullable(em.find(AuthUser.class,id)));
      }

      public Optional<AuthUser> findByUsername(String username){
        return execute(em->{
            List<AuthUser> users = em.createQuery(
                    "select u from AuthUser u where lower(u.username) = lower(:username)", AuthUser.class)
                    .setParameter("username",username)
                    .getResultList();
            return users.isEmpty() ? Optional.empty() : Optional.of(users.get(0));
        });
      }

      public List<AuthUser> searchByusernamePrefix(String prefix, int limit){
          return execute(em->em.createQuery(
                  "select  u from AuthUser u where lower(u.username) ilike  lower(:prefix) and u.status <> :blk order by u.username asc ", AuthUser.class)
                  .setParameter("prefix",prefix+"%")
                  .setParameter("blk", uz.pdp.mini_blok_with_jakarta.enums.Status.BLOK)
                  .setMaxResults(limit)
                  .getResultList());
      }
}
