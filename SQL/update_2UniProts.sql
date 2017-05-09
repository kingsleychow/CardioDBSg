/*
get substitution scores from BLOSUM and PAM (based on 2UniProts)
*/
UPDATE 2UniProts p 
JOIN V2Ensembls e on p.vid=e.id -- and e.p_ref regexp '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]' and e.mut regex '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]'
JOIN ESST.SubMat m1 on m1.aa1=e.p_ref and m1.aa2=e.p_mut and m1.matrix='BLOSUM62' 
JOIN ESST.SubMat m2 on m2.aa1=e.p_ref and m2.aa2=e.p_mut and m2.matrix='PAM70'
SET p.blosum62=m1.lor, p.pam70=m2.lor
where (p.blosum62 is null) or (p.pam70 is null);
