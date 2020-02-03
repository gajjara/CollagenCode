function lightsource=blueLEDm470L3(~)
lightsource.name='ThorLabs M470-L3-C5';
lightsource.units='Watts and meters, including wavelengths';
lightsource.powerfromLED=0.710; % Watts Typical
lightsource.irradiance_at200mm=21.9; % W/m^2 = 21.9uW/mm^2 (bare
                                     % chip)
%lightsource.power=0.300; % 300 mw out of lens
lightsource.power = 0.09; % Calculated power 0.009Watts
lightsource.size=1e-3; % meters (assume 1mm square)
lightsource.aperture=43e-3; % 43 mm beam diameter out of lens
lightsource.focallength=40e-3;
lightsource.radiance=lightsource.power/lightsource.size^2/...
    (pi*lightsource.aperture^2/4)*lightsource.focallength^2;
data=[
194	0.001973
195	0.002364
196	0.000762
197	-0.000176
198	0.000253
199	0.000803
200	-0.001376
201	-0.000955
202	-0.002
203	-0.000604
204	-0.001078
205	0.000152
206	0.000557
207	0.000455
208	-0.001266
209	0.00021
210	0.000737
211	-0.002513
212	-0.000963
213	-0.002211
214	-0.000894
215	-0.001008
216	0.000705
217	0.000637
218	-0.00059
219	0.000894
220	-0.000308
221	-0.001241
222	-0.001755
223	0.000631
224	-0.000551
225	-0.000365
226	-0.001386
227	-0.000614
228	0.00045
229	-0.001141
230	-0.000523
231	-0.002225
232	-0.000838
233	0.000531
234	-0.001546
235	0.001197
236	-0.000159
237	0.00059
238	-0.000496
239	0.001912
240	0.000836
241	0.000793
242	-0.000574
243	-0.000931
244	-0.00117
245	-0.000951
246	-0.000595
247	-0.00253
248	0.000186
249	0.001116
250	0.000813
251	0.002778
252	-0.000642
253	-0.000253
254	0.000312
255	-0.000632
256	0.001019
257	-0.001332
258	-0.001133
259	-0.000182
260	-0.000319
261	0.000359
262	-0.000725
263	0.000121
264	-0.001204
265	0.000211
266	-0.000219
267	-0.001255
268	0.000274
269	-0.000246
270	0.000971
271	0.000248
272	0.000912
273	-0.00007
274	-0.001238
275	-0.000253
276	-0.001477
277	-0.001804
278	0.000587
279	0.000411
280	0.000264
281	-0.000181
282	-0.000879
283	-0.001013
284	0.000263
285	0.00157
286	0.000696
287	0.000094
288	0.000454
289	0.001045
290	-0.000961
291	-0.002069
292	-0.001637
293	0.000428
294	0.000017
295	-0.001636
296	0.00098
297	0.000316
298	-0.000825
299	0.001732
300	-0.001268
301	0.001091
302	0.000934
303	-0.001355
304	0.000797
305	-0.001616
306	-0.000214
307	0.000503
308	0.000132
309	-0.000011
310	0.00086
311	-0.000002
312	0.000618
313	0.000192
314	0.000442
315	-0.00122
316	-0.001682
317	-0.001613
318	0.000491
319	0.000478
320	-0.000809
321	-0.00021
322	-0.000157
323	0.000354
324	0.000751
325	-0.001213
326	-0.002255
327	0.000883
328	-0.000425
329	-0.001371
330	0.000648
331	0.000937
332	-0.001565
333	0.000015
334	-0.000166
335	0.000667
336	-0.000449
337	0.000216
338	-0.001342
339	0.002047
340	-0.000593
341	-0.00057
342	0.000152
343	-0.001038
344	-0.001584
345	0.000051
346	-0.000636
347	-0.00087
348	0.003268
349	0.000261
350	-0.001053
351	0.000886
352	0.000679
353	0.000674
354	-0.000568
355	-0.00143
356	-0.001771
357	0.000627
358	-0.001551
359	-0.000378
360	0.000874
361	-0.000952
362	-0.000009
363	0.000365
364	-0.001001
365	-0.000293
366	-0.000821
367	0.000345
368	0.000652
369	0.001065
370	0.000946
371	-0.000002
372	-0.000291
373	0.001723
374	0.000817
375	-0.001366
376	0.000671
377	-0.000602
378	-0.000996
379	0.000146
380	-0.000044
381	-0.000682
382	-0.000237
383	0.000419
384	-0.001461
385	-0.00086
386	-0.000039
387	-0.000236
388	0.000943
389	-0.001421
390	-0.000906
391	-0.000926
392	0.000208
393	0.000883
394	0.000467
395	-0.000407
396	0.0014
397	0.0003
398	-0.00059
399	0.000265
400	-0.000897
401	-0.001527
402	-0.000739
403	0.001274
404	-0.000118
405	0.000219
406	-0.000385
407	-0.000544
408	-0.00103
409	0.000002
410	0.000556
411	-0.001096
412	0.001148
413	-0.001856
414	-0.001075
415	-0.002234
416	-0.000765
417	-0.000638
418	-0.000207
419	-0.000078
420	-0.000044
421	0.000179
422	0.000259
423	0.000011
424	-0.000983
425	0.000998
426	-0.000842
427	0.00029
428	-0.001875
429	0.001495
430	-0.001332
431	-0.000385
432	0.00296
433	0.002192
434	0.004599
435	0.008367
436	0.015125
437	0.021669
438	0.039411
439	0.058497
440	0.076304
441	0.095528
442	0.123117
443	0.148597
444	0.175308
445	0.209837
446	0.247067
447	0.286358
448	0.331659
449	0.375581
450	0.425726
451	0.489761
452	0.543456
453	0.610759
454	0.674866
455	0.735202
456	0.788187
457	0.851955
458	0.909145
459	0.944896
460	0.983692
461	0.99513
462	0.989089
463	0.961801
464	0.928661
465	0.87486
466	0.802909
467	0.7254
468	0.659615
469	0.594192
470	0.515866
471	0.455503
472	0.395966
473	0.350034
474	0.299011
475	0.255389
476	0.216778
477	0.186901
478	0.163145
479	0.136254
480	0.113487
481	0.094782
482	0.079687
483	0.062155
484	0.053789
485	0.043523
486	0.032131
487	0.023456
488	0.015686
489	0.01393
490	0.01137
491	0.008317
492	0.005554
493	0.003819
494	0.003558
495	0.003335
496	0.00199
497	0.002013
498	0.000972
499	-0.000287
500	0.000625
501	0.00094
502	-0.000259
503	0.000504
504	-0.000728
505	0.001602
506	0.000272
507	-0.00134
508	-0.0001
509	-0.000133
510	0.000194
511	-0.00024
512	-0.000078
513	0.000415
514	-0.000012
515	0.000128
516	0.000783
517	0.00057
518	-0.000272
519	-0.00152
520	0.001601
521	-0.000687
522	-0.000784
523	-0.000342
524	-0.000486
525	-0.000819
526	0.000682
527	-0.000297
528	-0.001137
529	0.000084
530	0.001599
531	0.000979
532	-0.000832
533	-0.00029
534	-0.000441
535	-0.000793
536	0.000398
537	-0.000624
538	-0.001983
539	0.000023
540	-0.000449
541	0.000337
542	0.000373
543	-0.001515
544	-0.001215
545	0.000124
546	0.000872
547	-0.001772
548	-0.000046
549	-0.001388
550	-0.001652
551	-0.000804
552	-0.001099
553	-0.000178
554	-0.000375
555	0.000662
556	0.000291
557	-0.002537
558	0.000279
559	-0.000353
560	-0.001171
561	0.000262
562	-0.000803
563	-0.000455
564	0.000281
565	-0.000383
566	0.00036
567	-0.002821
568	-0.000127
569	0.000505
570	0.001737
571	0.000222
572	-0.00137
573	-0.00135
574	0.000815
575	-0.001203
576	-0.001463
577	-0.000716
578	0.001838
579	-0.0002
580	-0.000378
581	-0.000999
582	0.000012
583	0.000331
584	-0.001186
585	0.000549
586	0.000464
587	-0.000948
588	-0.001033
589	-0.001962
590	0.001121
591	-0.0012
592	-0.000196
593	-0.000197
594	0.000441
595	-0.001681
596	0.000856
597	-0.001744
598	0.000332
599	0.001194
600	-0.000051
601	0.001772
602	0.001753
603	0.000495
604	0.000451
605	0.000655
606	0.001796
607	-0.000649
608	-0.001429
609	0.000203
610	-0.000397
611	0.000345
612	0.000518
613	0.000502
614	-0.000675
615	-0.000771
616	-0.001048
617	0.000925
618	0.000373
619	-0.001878
620	0.000278
621	-0.000617
622	0.000169
623	-0.000504
624	-0.000373
625	-0.000294
626	0.000051
627	0.000564
628	0.000908
629	-0.001851
630	-0.000895
631	-0.000864
632	0.000325
633	-0.000322
634	0.000542
635	-0.000951
636	-0.002771
637	0.00009
638	0.001093
639	-0.000304
640	-0.000461
641	0.000106
642	-0.001037
643	0.000319
644	-0.000706
645	0.000455
646	0.000118
647	-0.001636
648	-0.002167
649	-0.001461
650	-0.000224
651	0.003485
652	-0.001116
653	-0.00099
654	-0.000476
655	0.001329
656	-0.000117
657	0.000946
658	-0.000309
659	0.000015
660	-0.000803
661	-0.00029
662	0.000337
663	0.00023
664	-0.000472
665	-0.000102
666	-0.000303
667	0.000643
668	-0.000767
669	-0.001107
670	-0.001188
671	0.001494
672	0.000056
673	-0.000034
674	-0.000611
675	0.000508
676	-0.000105
677	0.000263
678	0.001131
679	0.00183
680	-0.000672
681	-0.000514
682	-0.001294
683	-0.00062
684	-0.000298
685	0.00108
686	0.000331
687	-0.000313
688	0.000046
689	0.000427
690	-0.000351
691	0.00032
692	0.000392
693	0.000813
694	-0.00041
695	0.000603
696	0.000523
697	-0.000385
698	-0.001159
699	0.000084
700	0.001509
701	0.000046
702	-0.000576
703	-0.001062
704	-0.001013
705	0.000115
706	0.000111
707	0.000523
708	-0.000894
709	-0.000545
710	0.000225
711	-0.000221
712	0.000039
713	-0.00041
714	-0.002412
715	-0.000961
716	-0.000413
717	0.000219
718	0.000776
719	0.000143
720	-0.001297
721	-0.000883
722	-0.00025
723	0.000076
724	0.000785
725	-0.000722
726	0.000227
727	0.002585
728	0.001099
729	-0.000444
730	-0.000583
731	-0.001227
732	0.002232
733	-0.001108
734	-0.000257
735	-0.003024
736	-0.00014
737	0.000177
738	0.001751
739	-0.001658
740	-0.001366
741	0.00032
742	0.001384
743	-0.000343
744	0.000769
745	-0.001134
746	0.000438
747	-0.001088
748	-0.000144
749	0.001627
750	-0.000798
751	0.000947
752	-0.000163
753	0.000389
754	-0.000473
755	0.002546
756	-0.000514
757	0.000288
758	0.000589
759	-0.000452
760	-0.001388
761	0.000838
762	-0.000455
763	-0.001051
764	-0.00223
765	0.000073
766	-0.000072
767	-0.00026
768	-0.001501
769	-0.000549
770	0.000687
771	-0.000928
772	0.0003
773	0.00008
774	0.000209
775	-0.000784
776	0.000777
777	-0.001197
778	-0.002116
779	-0.00026
780	-0.001119
781	-0.001455
782	-0.001509
783	0.001546
784	0.000181
785	-0.000632
786	-0.000186
787	-0.0007
788	-0.000689
789	0.000755
790	-0.000202
791	-0.001499
792	0.00084
793	0.000394
794	-0.000693
795	0.001284
796	-0.001969
797	-0.000545
798	-0.001035
799	0.00058
800	0.000042
801	-0.000185
802	0.000188
803	0.000408
804	-0.000481
805	-0.000288
806	0.000343
807	-0.000388
808	-0.000084
809	0.000734
810	0.000894
811	-0.001456
812	0.000847
813	0.000014
814	0.000395
815	-0.000152
816	0.000218
817	-0.00113
818	-0.001197
819	-0.002315
820	-0.003052
821	-0.000174
822	-0.000717
823	-0.000073
824	0.001391
825	0.000437
826	-0.000467
827	-0.000152
828	-0.001796
829	-0.000156
830	-0.002625
831	0.000611
832	-0.000423
833	0.000017
834	0.000197
835	-0.000211
836	-0.000675
837	-0.001054
838	-0.001313
839	-0.001227
840	0.000604
841	-0.001062
842	-0.000899
843	0.000675
844	0.000131
845	0.00016
846	-0.000663
847	0.001431
848	-0.00076
849	0.000635
850	-0.00215
851	0.000011
852	-0.002142
853	0.000101
854	-0.000856
855	-0.000854
856	0.000791
857	0.001282
858	-0.000399
859	-0.000784
860	-0.000365
861	-0.000214
862	-0.000288
863	-0.000604
864	-0.001733
865	-0.000533
866	0.000559
867	0.000586
868	0.000905
869	0.001568
870	-0.000899
871	-0.000051
872	0.00027
873	0.001343
874	-0.001051
875	0.000793
876	-0.000399
877	-0.000084
878	-0.000253
879	0.000096
880	0.001254
881	-0.003086
882	-0.001456
883	0.001265
884	-0.000826
885	0.000343
886	0.000309
887	-0.001332
888	-0.001439
889	0.000489
890	-0.000219
891	-0.001445
892	-0.001107
893	-0.00231
894	-0.001762
895	0.000129
896	-0.001099
897	-0.001218
898	0.000105
899	0.000839
900	0.00118
901	0.000624
902	0.000517
903	-0.000708
904	0.000478
905	0.00075
906	0.000725
907	0.0005
908	-0.000759
909	-0.001147
910	0.001051
911	0.000091
912	0.000666
913	-0.001252
914	0.000945
915	0.000349
916	-0.000739
917	-0.001552
918	0.000341
919	-0.000107
920	-0.001107
921	0.000399
922	-0.000689
923	-0.002234
924	-0.000564
925	-0.000259
926	0.000868
927	0.001039
928	-0.001488
929	0.00086
930	-0.00077
931	-0.000864
932	-0.000417
933	0.000022
934	0.000152
935	0.000181
936	-0.000735
937	-0.000208
938	0.001137
939	-0.0014
940	0.000641
941	-0.00059
942	-0.000569
943	0.00025
944	-0.001186
945	-0.000624
946	0.001731
947	-0.000073
948	0.000287
949	0.000747
950	0.000354
951	-0.000282
952	-0.000416
953	-0.000958
954	-0.000132
955	0.000096
956	-0.001062
957	-0.001217
958	0.001521
959	-0.000729
960	0.000957
961	0.00059
962	0.000426
963	-0.001029
964	-0.000664
965	-0.001067
966	-0.00122
967	-0.001152
968	0.000467
969	-0.000388
970	-0.000604
971	-0.000107
972	0.000447
973	-0.001254
974	-0.000153
975	0.000888
976	0.000608
977	-0.001753
978	-0.000188
979	0.001067
980	0.000304
981	0.000194
982	-0.000379
983	-0.000717
984	0.00113
985	0.000502
986	-0.001223
987	-0.001935
988	-0.000641
989	0.000987
990	0.001324
991	-0.000316
992	0.000422
993	-0.001484
994	0.000177
995	-0.000008
996	-0.000455
997	0.000388
998	0.000067
999	0.000894
1000	0.001872
1001	-0.000186
1002	0.002175
1003	-0.000961
1004	-0.000455
1005	0.000691
1006	-0.001141
1007	-0.000388
1008	0.000084
1009	0.000523
1010	-0.00086
1011	0.000691
1012	0.000118
1013	0.001265
1014	0.000601
1015	-0.00122
1016	0.001535
1017	0.000826
1018	-0.001433
1019	0.001355
1020	0.000219
1021	-0.000354
];
lightsource.wavelength=data(:,1)*1e-9; % meters
lightsource.spectrum=data(:,2); % Probably arbitrary units
clear data;
lightsource.spectral_radiance=lightsource.spectrum*...
    lightsource.radiance/...
     trapni(lightsource.spectrum,lightsource.wavelength);
% Watts/m^2/sr/m - Verified that it integrates to the original
% radiance 
end

