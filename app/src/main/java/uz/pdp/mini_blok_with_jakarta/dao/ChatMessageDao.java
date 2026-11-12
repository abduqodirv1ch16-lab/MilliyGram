package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.ChatMessage;

import java.util.List;
import java.util.Optional;

public class ChatMessageDao extends BaseDao{
    public void save(ChatMessage message){
        executeInTransaction(em->em.persist(message));
    }

    public void update(ChatMessage message){
        executeInTransaction(em->em.merge(message));
    }

    public Optional<ChatMessage> findById(Integer id){
        return execute(em->Optional.ofNullable(em.find(ChatMessage.class,id)));
    }

    public List<ChatMessage> getChatHistory(Integer user1Id, Integer user2Id ){
        return execute(em->em.createQuery(
                "select m from  ChatMessage m where "+
                        "(m.senderId=:u1 and m.receiverId=:u2) or (m.senderId=:u2 and m.receiverId=:u1)"+
                        "order by m.createdAt asc ", ChatMessage.class)
                .setParameter("u1", user1Id)
                .setParameter("u2",user2Id)
                .getResultList());
    }

    public void softDelete(Integer messageId, Integer senderId){
        executeInTransaction(em->em.createQuery(
                "update ChatMessage m set m.isDeleted=true where m.id=:id and m.senderId=:senderId")
                .setParameter("id",messageId)
                .setParameter("senderId",senderId)
                .executeUpdate());
    }

}
