package uz.pdp.mini_blok_with_jakarta.dao;

import uz.pdp.mini_blok_with_jakarta.entity.Complaint;

public class ComplaintDao extends BaseDao{
    public void save(Complaint complain){
        executeInTransaction(em->em.persist(complain));
    }
}
