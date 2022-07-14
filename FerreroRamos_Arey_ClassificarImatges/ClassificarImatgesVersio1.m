function precision=ClassificarImatgesVersio1(name_folder, name_check_file)
    folder=dir(name_folder);                                                    % Es genera una variable que conté el nom dels arxius que contenen les imatges, a partir del path del directori que els conté.
    checker=readtable(name_check_file);                                         % Es llegeix el contingut del fitxer de verificació '.csv' i s'emmagatzema en una variable.
    cont_correct_images=0;
    cont_images=0;
    for num_image=3:length(folder)                                              % Es comença desde el tercer arxiu del directori, perquè el primer arxiu és el propi directori i el segon és el seu directori pare.
        ima=imread(append(name_folder, folder(num_image).name));                % Es carrega la imatge en una variable a partir del path del directori i del nom de l'arixu que la conté.
        ima_equal=adapthisteq(ima);                                             % Es fa una equalització adaptativa per millorar el contrast.
        ima_bin=~imbinarize(ima_equal);                                         % Es binaritza la imatge utilitzant un llindar global.
        se=strel('diamond', 2);                                                 % El diamant, el disc o l'esfera son igual de vàlids com a elements estructurants.
        ima_closed=imerode(imdilate(ima_bin, se), se);                          % S'ha d'aplicar un 'closing' per reomplir els cucs. 
        ima_opened=imdilate(imerode(ima_closed, se), se);                       % S'ha d'aplicar un 'opening' per eliminar soroll i, sobre tot, per separar els cucs que estan molt junts.  
        worms=bwareafilt(ima_opened, [300 3000]);                               % S'extreuen tots aquells objectes de la imatge que tinguin un tamany semblant al que s'espera que tinguin els cucs. Amb això s'aconsegueix eliminar soroll i el marc.
        features=bwconncomp(worms);                                             % S'obtenen els components connectats de la imatge. Aquesta informació és necessària per a la posterior extracció de les característiques d'interés.
        measures=regionprops(features, 'MajorAxisLength', 'MinorAxisLength');   % S'obté el valor dels eixos major i menor de l'elipse englobant de cada un dels cucs. S'utilitzen per calcular la relació d'aspecte.
        num_live=0;
        num_dead=0;
        for i=1:features.NumObjects                                             % Per cada cuc dels que s'han extret de la imatge.
            if (measures(i).MajorAxisLength/measures(i).MinorAxisLength < 8)    % Es comprova si la relació d'aspecte d'un cuc és inferior o superior a 8.
                num_live=num_live+1;                                            % Si és inferior, s'asumeix que el cuc està viu.                                               
            else
                num_dead=num_dead+1;                                            % Si és superior, s'asumeix que està mort. 
            end
        end
        if (num_live > num_dead)                                                % Es comprova si hi ha més cucs vius que morts.
            classify='alive';                                                   % Si hi ha més cucs vius, la imatge es classifica en la categoria de cucs vius.             
        else
            classify='dead';                                                    % Si hi ha més cucs morts, la imatge es classifica en la categoria de cucs morts.
        end
        if (strcmp(classify, checker{num_image-2, "Status"}))                   % Es comprova si la clasificació de la imatge ha estat correcta.
            cont_correct_images=cont_correct_images+1;                          % Si ha estat correcta, s'incrementa el nombre d'imatges classificades correctament.
        end
        cont_images=cont_images+1;                                              % S'incrementa el nombre d'imatges tractades.
    end
    precision=(cont_correct_images/cont_images)*100;                            % Per calcular la precisió, es divideix el nombre d'imatges clasificades correctament entre el nombre d'imatges tractades.
end