package uz.pdp.mini_blok_with_jakarta.service;

import uz.pdp.mini_blok_with_jakarta.dao.ComplaintDao;
import uz.pdp.mini_blok_with_jakarta.dao.FollowDao;
import uz.pdp.mini_blok_with_jakarta.dao.PostLikeDao;
import uz.pdp.mini_blok_with_jakarta.dao.SavedPostDao;
import uz.pdp.mini_blok_with_jakarta.entity.Complaint;

public class InteractionService {
    private final PostLikeDao postLikeDao = new PostLikeDao();
    private final SavedPostDao savedPostDao = new SavedPostDao();
    private final FollowDao followDao = new FollowDao();
    private final ComplaintDao complaintDao = new ComplaintDao();

    public boolean togglePostLike(Integer userId, Integer postId){
        return postLikeDao.toggleLike(userId, postId);
    }

    public boolean toggleSavePost(Integer userId, Integer postId){
        return savedPostDao.toggleSave(userId, postId);
    }
    public boolean toggleFollow(Integer followerId ,Integer followingId){
        if(followerId.equals(followingId)) return false;
        return followDao.toggleFollow(followerId,followingId);
    }
    public void reportPost(Integer  userId, Integer postId, String reason){
        Complaint complaint = Complaint.builder()
                .userId(userId)
                .postId(postId)
                .reason(reason)
                .build();
        complaintDao.save(complaint);
    }

}
