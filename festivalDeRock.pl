% festival(NombreDelFestival, Bandas, Lugar).
% Relaciona el nombre de un festival con la lista de los nombres de bandas que tocan en él y el lugar dónde se realiza.
festival(lollapalooza, [gunsAndRoses, theStrokes, littoNebbia], hipodromoSanIsidro).
festival(lollapalooza, [gunsAndRoses, theStrokes, littoNebbia], laRural).
festival(personalFest, [rombai, losDelEspacio, marama, duki], movistarArena).
festival(buenosAiresTrap, [modoDiablo, duki, barderos, ysyA], estadioVelez).
festival(rockAndRoll, [divididos, enanitosVerdes, losRedondos], estadoUnicoDeLaPlata).

% lugar(nombre, capacidad, precioBase).
% Relaciona un lugar con su capacidad y el precio base que se cobran las entradas ahí.
lugar(hipodromoSanIsidro, 85000, 3000).
lugar(laRural, 60000, 2000).
lugar(movistarArena, 70000, 3500).
lugar(estadioVelez, 68000, 4000).
lugar(estadoUnicoDeLaPlata, 90000, 5000).

% banda(nombre, nacionalidad, popularidad).
% Relaciona una banda con su nacionalidad y su popularidad.
banda(gunsAndRoses, eeuu, 69420).
banda(divididos, argentina, 30000).
banda(enanitosVerdes, argentina, 20000).
banda(losRedondos, argentina, 50000).
banda(duki, argentina, 70000).
banda(ysy, argentina, 90000).
banda(barderos, argentina, 20000).
banda(marama, uruguay, 30000).

% entradaVendida(NombreDelFestival, TipoDeEntrada).
% Indica la venta de una entrada de cierto tipo para el festival 
% indicado.
% Los tipos de entrada pueden ser alguno de los siguientes: 
%     - campo
%     - plateaNumerada(Fila)
%     - plateaGeneral(Zona).
entradaVendida(lollapalooza, campo).
entradaVendida(lollapalooza, plateaNumerada(1)).
entradaVendida(lollapalooza, plateaGeneral(zona2)).

entradaVendida(buenosAiresTrap, plateaGeneral(zona1)).
entradaVendida(buenosAiresTrap, plateaGeneral(zona2)).
entradaVendida(buenosAiresTrap, plateaNumerada(1)).
entradaVendida(buenosAiresTrap, plateaNumerada(15)).

% Entradas PersonalFest
entradaVendida(personalFest, campo).
entradaVendida(personalFest, campo).
entradaVendida(personalFest, plateaGeneral(zona1)).
entradaVendida(personalFest, plateaGeneral(zona2)).
entradaVendida(personalFest, plateaGeneral(zona3)).
entradaVendida(personalFest, plateaGeneral(zona4)).
entradaVendida(personalFest, plateaNumerada(8)).


% Entradas Rock&Roll
entradaVendida(rockAndRoll, campo).
entradaVendida(rockAndRoll, campo).
entradaVendida(rockAndRoll, campo).
entradaVendida(rockAndRoll, plateaGeneral(zona1)).
entradaVendida(rockAndRoll, plateaGeneral(zona2)).
entradaVendida(rockAndRoll, plateaNumerada(4)).



% plusZona(Lugar, Zona, Recargo)
% Relacion una zona de un lugar con el recargo que le aplica al precio de las plateas generales.
% Hipodromo de Palermo
plusZona(hipodromoSanIsidro, zona1, 1500).
plusZona(hipodromoSanIsidro, zona2, 2000).
plusZona(hipodromoSanIsidro, zona3, 2500).

% La rural
% No tiene zonas plus

% Movistar Arena
plusZona(movistarArena, zona1, 1000).
plusZona(movistarArena, zona2, 2000).
plusZona(movistarArena, zona3, 3000).
plusZona(movistarArena, zona4, 4000).

% Estadui Velez
plusZona(estadioVelez, zona1, 2000).
plusZona(estadioVelez, zona2, 4000).
plusZona(estadioVelez, zona3, 6000).

% Estadio Unico de La Plata
plusZona(estadoUnicoDeLaPlata, zona1, 1000).
plusZona(estadoUnicoDeLaPlata, zona2, 3000).
% Punto 1
% itinerante/1: Se cumple para los festivales que ocurren en más de un lugar, pero con el mismo nombre y las mismas bandas en el mismo orden.
itinerante(Festival):-
    festival(Festival, Bandas, Lugar),
    festival(Festival, Bandas, OtroLugar),
    Lugar \= OtroLugar.

% Punto 2
% careta/1: Decimos que un festival es careta si no tiene campo o si es el personalFest.
careta(personalFest).
careta(Festival):-
    festival(Festival, _, _),
    forall(entradaVendida(Festival, TipoDeEntrada), TipoDeEntrada \= campo).

% Punto 3
% nacAndPop/1: Un festival es nac&pop si no es careta y todas las bandas que tocan en él son de nacionalidad argentina y tienen popularidad mayor a 1000.
nacAndPop(Festival):-
    festival(Festival, Bandas, _),
    not(careta(Festival)),
    forall(member(Banda, Bandas), (banda(Banda, argentina, Popularidad), Popularidad > 1000)).

% Punto 4
% sobrevendido/1: Se cumple para los festivales que vendieron más entradas que la capacidad del lugar donde se realizan.
% Nota: no hace falta contemplar si es un festival itinerante.
sobrevendido(Festival):-
    festival(Festival, _, Lugar),
    lugar(Lugar, Capacidad, _),
    findall(TipoDeEntrada, entradaVendida(Festival, TipoDeEntrada), EntradasVendidas),
    length(EntradasVendidas, Cantidad),
    Cantidad > Capacidad.

% Punto 5
% recaudaciónTotal/2: Relaciona un festival con el total recaudado con la venta de entradas. Cada tipo de entrada se vende a un precio diferente:
%    - El precio del campo es el precio base del lugar donde se realiza el festival.
%    - La platea general es el precio base del lugar más el plus que se p aplica a la zona. 
%    - Las plateas numeradas salen el triple del precio base para las filas de atrás (>10) y 6 veces el precio base para las 10 primeras filas.
% Nota: no hace falta contemplar si es un festival itinerante.
recaudacionTotal(Festival, TotalRecaudado):-
    festival(Festival, _, Lugar),
    findall(Precio, (entradaVendida(Festival, TipoEntrada), precioEntrada(Lugar, TipoEntrada, Precio)), Precios),
    sumlist(Precios, TotalRecaudado).

precioEntrada(Lugar, campo, Precio):-
    lugar(Lugar, _, Precio).
precioEntrada(Lugar, plateaGeneral(Zona), Precio):-
    lugar(Lugar, _, PrecioBase),
    plusZona(Lugar, Zona, Recargo),
    Precio is PrecioBase + Recargo.
precioEntrada(Lugar, plateaNumerada(Fila), Precio):-
    lugar(Lugar, _, PrecioBase),
    Fila > 10,
    Precio is (PrecioBase * 3).
precioEntrada(Lugar, plateaNumerada(Fila), Precio):-
    lugar(Lugar, _, PrecioBase),
    Fila =< 10,
    Precio is (PrecioBase * 6).

% Punto 6
% delMismoPalo/2: Relaciona dos bandas si tocaron juntas en algún recital o si una de ellas tocó con una banda del mismo palo que la otra, pero más popular.
delMismoPalo(UnaBanda, OtraBanda):-
    tocaronJuntas(UnaBanda, OtraBanda).
delMismoPalo(UnaBanda, OtraBanda):-
    tocaronJuntas(UnaBanda, TerceraBanda),
    banda(TerceraBanda, _, PopularidadTercera),
    delMismoPalo(TerceraBanda, OtraBanda),
    banda(OtraBanda, _, PopularidadOtra),
    PopularidadTercera > PopularidadOtra.


tocaronJuntas(UnaBanda, OtraBanda):-
    festival(_, Bandas, _),
    member(UnaBanda, Bandas),
    member(OtraBanda, Bandas),
    UnaBanda \= OtraBanda.


    