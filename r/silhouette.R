library(cluster)
ngrams=read.table("data\\ngram_vectors_all_0227.txt")
colnames(ngrams)=c("tfdf-1","tf-2","df-3","cvalue-4","umls_score-5","chv_score-6","contain_umls-7","contain_chv-8","nn-9","an-10","pn-11","anpn-12","stys-13","stys-14","stys-15","stys-16","stys-17","stys-18","stys-19","stys-20","stys-21","stys-22","stys-23","stys-24","win_pos-25","win_pos-26","win_pos-27","win_pos-28","win_pos-29","win_pos-30","win_pos-31","win_pos-32","win_pos-33","win_pos-34","win_pos-35","win_pos-36","win_pos-37","capt_first-38","capt_all-39","capt_term-40","win_umls-41","win_chv-42","sent_umls-43","sent_chv-44","umls_dist-45","chv_dist-46","prefix-47","prefix-48","prefix-49","prefix-50","prefix-51","prefix-52","prefix-53","prefix-54","prefix-55","prefix-56","prefix-57","prefix-58","prefix-59","prefix-60","prefix-61","prefix-62","prefix-63","prefix-64","prefix-65","prefix-66","prefix-67","prefix-68","prefix-69","prefix-70","prefix-71","prefix-72","prefix-73","prefix-74","prefix-75","prefix-76","prefix-77","prefix-78","prefix-79","prefix-80","prefix-81","prefix-82","prefix-83","prefix-84","prefix-85","prefix-86","prefix-87","prefix-88","prefix-89","prefix-90","prefix-91","prefix-92","prefix-93","prefix-94","prefix-95","prefix-96","prefix-97","prefix-98","prefix-99","prefix-100","prefix-101","prefix-102","prefix-103","prefix-104","prefix-105","prefix-106","prefix-107","prefix-108","prefix-109","prefix-110","prefix-111","prefix-112","prefix-113","prefix-114","prefix-115","prefix-116","prefix-117","prefix-118","prefix-119","prefix-120","suffix-121","suffix-122","suffix-123","suffix-124","suffix-125","suffix-126","suffix-127","suffix-128","suffix-129","suffix-130","suffix-131","suffix-132","suffix-133","suffix-134","suffix-135","suffix-136","suffix-137","suffix-138","suffix-139","suffix-140","suffix-141","suffix-142","suffix-143","suffix-144","suffix-145","suffix-146","suffix-147","suffix-148","suffix-149","suffix-150","suffix-151","suffix-152","suffix-153","suffix-154","suffix-155","suffix-156","suffix-157","suffix-158","suffix-159","suffix-160","suffix-161","suffix-162","suffix-163","suffix-164","suffix-165","suffix-166","suffix-167","suffix-168","suffix-169","suffix-170","suffix-171","suffix-172","suffix-173","suffix-174","suffix-175","suffix-176","suffix-177","suffix-178","suffix-179","suffix-180","suffix-181","suffix-182","suffix-183","suffix-184","suffix-185","suffix-186","suffix-187","suffix-188","suffix-189","suffix-190","suffix-191","suffix-192","suffix-193","suffix-194","suffix-195","suffix-196","suffix-197","suffix-198","suffix-199","suffix-200","suffix-201","suffix-202","suffix-203","suffix-204","suffix-205","suffix-206","suffix-207","suffix-208","suffix-209","suffix-210","suffix-211","suffix-212","suffix-213","suffix-214","suffix-215","suffix-216","suffix-217","suffix-218","suffix-219","suffix-220","suffix-221","suffix-222","suffix-223","suffix-224","suffix-225","suffix-226","suffix-227","suffix-228","suffix-229","suffix-230","suffix-231","suffix-232","suffix-233","suffix-234","suffix-235","suffix-236","suffix-237","suffix-238","suffix-239","suffix-240","suffix-241","suffix-242","suffix-243","suffix-244","suffix-245","suffix-246","suffix-247","suffix-248","suffix-249","suffix-250","suffix-251","suffix-252","suffix-253","suffix-254","suffix-255","suffix-256","suffix-257","suffix-258","suffix-259","suffix-260","suffix-261","suffix-262","suffix-263","suffix-264","suffix-265","suffix-266","suffix-267","suffix-268","suffix-269","suffix-270","suffix-271","suffix-272","suffix-273","suffix-274","suffix-275","suffix-276","suffix-277","suffix-278","suffix-279","suffix-280","suffix-281","suffix-282","suffix-283","suffix-284","suffix-285","suffix-286","suffix-287","suffix-288","suffix-289","suffix-290","suffix-291","suffix-292","suffix-293","suffix-294","suffix-295","suffix-296","suffix-297","suffix-298","suffix-299","suffix-300","suffix-301","suffix-302","suffix-303","suffix-304","suffix-305","suffix-306","suffix-307","suffix-308","suffix-309","suffix-310","suffix-311","suffix-312","suffix-313")
v=subset(ngrams,`chv_score-6`>0.3)
#v$`chv_score-6`=0
dissE <- daisy(v)

msk = c()
kkk=seq(2,20,1)
for (k in kkk) {
  km <- kmeans(v,k,iter.max = 1000,nstart=10)
  sk <- silhouette(km$cluster, dissE)
  #print(summary(sk))
  print(mean(sk[,3]))
  msk = append(msk,mean(sk[,3]))
  #plot(sk)
}

#tiff("Plot2.tif", res = 300)

plot(cbind(kkk,msk),type='b',xlab = "Number of clusters", ylab="Silhouette score")


#sss=c(0.2643342,0.2798345,0.2909478,0.2932777,0.2771142,0.258752,0.2134653,0.217159,0.181204,0.1885766,0.1786644,0.1713124,0.206528,0.1611574,0.1845627,0.1712207,0.152299,0.1767387,0.157803,0.1702419,0.1557435,0.1296721,0.1368338,0.1490912,0.1171227,0.1211971,0.1221018,0.1244477,0.1108768,0.1215782,0.1197631,0.1129861,0.1221741,0.1015608,0.1007896,0.1075403)
#cluster=c(seq(2,20,1),seq(20,100,5))
#plot(cluster,sss,type='b',xlab = "cluster number", ylab="Silhouette score")
