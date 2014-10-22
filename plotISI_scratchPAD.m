

figure(1)
hist(wc_ISI*1000,15)
xlim([0 max(wc_ISI*1000)])

figure(2)
hist(jat_ISI*1000,15)
xlim([0 max(jat_ISI*1000)])

mean_isi = mean(isi_vect)
std_isi = std(isi_vect)
CV_isi = mean_isi/std_isi
