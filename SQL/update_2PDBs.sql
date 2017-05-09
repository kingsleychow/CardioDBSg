	UPDATE 2PDBs p 
	JOIN V2Ensembls e on p.vid=e.id -- and e.p_ref regexp '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]' and e.p_mut regexp '[ABCDEFGHIJKLMNPQRSTVWXYZ\*]'
	JOIN ESST.ESST m on p.env=m.env and m.aa1=e.p_ref and m.aa2=e.p_mut
	SET p.esst=m.lor
	where p.esst is null 
	and m.matrix='ALL' and m.mat_type='MaskB';
