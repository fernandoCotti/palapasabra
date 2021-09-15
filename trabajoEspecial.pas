program palapasabra; //PARA CURSADA
uses crt;

type 
    punteroJugadores= ^tipoJugadores;
    tipoJugadores = record
        nombreJugador: string;
        partidasGanadas: integer;
        mayor, menor: punteroJugadores;
    end;
    
    tipoJug = record
        nombreJugador: string;
        partidasGanadas: integer;
    end;
    
    archivoJugadores = file of tipoJug;
    
    punteroRosco = ^tipoRosco;
    tipoRosco = record
        letra: char;
        respuesta: 1..3; // 1 = Acertada; 2= Errada; 3= Pendiente
        palabra, consigna: string;
        siguiente: punteroRosco;
    end;
    
    elementoArray = record
        nombre: string;
        rosco: punteroRosco;
    end;
    
    partida = array[1..2] of elementoArray;
    
    reg_palabra = record
        nro_set: integer;
        letra: char;
        palabra, consigna: string;
    end;
    
    archivoPalabras = file of reg_palabra;


procedure presionarTecla();
begin
    writeln('Presione cualquier tecla para continuar. ');
    ReadKey();
    ClrScr;
end;

procedure crearArbol(var arbolJug: punteroJugadores);
begin
    new(arbolJug);
    arbolJug:= nil;
end;

function nuevoJugador(nombre: string): punteroJugadores;
var
    puntero: punteroJugadores;
begin
    new(puntero);
    puntero^.nombreJugador:= nombre;
    puntero^.partidasGanadas:= 0;
    puntero^.mayor:= nil;
    puntero^.menor:= nil;
    nuevoJugador:= puntero;
end;

procedure insertarEnArbol(var arbolJugadores: punteroJugadores; nombre: string);
begin
    if (arbolJugadores = nil) then
        arbolJugadores:= nuevoJugador(nombre)
    else
    begin
        if (arbolJugadores^.nombreJugador > nombre) then
            insertarEnArbol(arbolJugadores^.menor, nombre)
        else
            if (arbolJugadores^.nombreJugador < nombre) then
                insertarEnArbol(arbolJugadores^.mayor, nombre)
    end;
end;

procedure insertarEnArchivo(var archivoJug: archivoJugadores; nombre: string);
var
    registro: tipoJug;
begin
    reset(archivoJug);
    registro.nombreJugador:= nombre;
    registro.partidasGanadas:= 0;
    write(archivoJug, registro);
    close(archivoJug);
end;

function estaEnArbol(arbolJugadores: punteroJugadores; nombre: string): boolean;
begin
    if (arbolJugadores <> nil) then
    begin
        if (arbolJugadores^.nombreJugador = nombre) then
            estaEnArbol:= true
        else 
            if (arbolJugadores^.nombreJugador > nombre) then
                estaEnArbol:= estaEnArbol(arbolJugadores^.menor, nombre)
            else
                estaEnArbol:= estaEnArbol(arbolJugadores^.mayor, nombre);
    end
    else
        estaEnArbol:= false;
end;

procedure agregarJugador(var arbolJugadores: punteroJugadores; var archivoJug: archivoJugadores);
var
    nombre: string;
begin
    write('Ingrese nombre a agregar: ');
    readln(nombre);
    while (estaEnArbol(arbolJugadores, nombre) = true) do
    begin
        writeln('Jugador ya existente, ingrese de nuevo: ');
        readln(nombre);
    end;
    insertarEnArbol(arbolJugadores, nombre);
    insertarEnArchivo(archivoJug, nombre);
    ClrScr;
end;


procedure ingresoJugador(var nombre: string; arbolJugadores: punteroJugadores);
begin
    writeln('Ingrese nombre de jugador: ');
    readln(nombre);
    while not (estaEnArbol(arbolJugadores, nombre) = true) do
    begin
        writeln('Jugador no encontrado, ingrese de nuevo: ');
        readln(nombre);
    end;
end;

function nuevoNodo(registro: reg_palabra): punteroRosco;
var
    puntero: punteroRosco;
begin
    new(puntero);
    puntero^.letra:= registro.letra;
    puntero^.respuesta:= 3;
    puntero^.palabra:= registro.palabra;
    puntero^.consigna:= registro.consigna;
    puntero^.siguiente:= nil;
    nuevoNodo:= puntero;
end;

procedure enlazarNodos(var rosco: punteroRosco);
var
    cursor: punteroRosco;
begin
    cursor:= rosco;
    while (cursor^.siguiente <> nil) do
        cursor:= cursor^.siguiente;
    cursor^.siguiente:= rosco;
end;

procedure insertarNodo(registro: reg_palabra; var listaRosco: punteroRosco);
begin
    if (listaRosco = nil) then
        listaRosco:= nuevoNodo(registro)
    else
        insertarNodo(registro, listaRosco^.siguiente);
end;

function posicionEnArchivo(r: integer): integer;
begin
    case r of
            1: posicionEnArchivo:= 0;
            2: posicionEnArchivo:= 26;
            3: posicionEnArchivo:= 52;
            4: posicionEnArchivo:= 78;
            5: posicionEnArchivo:= 104;
    end;
end;

procedure inicializarRosco(var palabras: archivoPalabras; var listaRosco: punteroRosco);
var
    r, pos, i: integer;
    registroPalabra: reg_palabra;
begin
    randomize;
    r:=random(5)+1;
    pos:= posicionEnArchivo(r);
    reset(palabras);
    new(listaRosco);
    seek(palabras, pos);
    for i:=1 to 26 do
    begin
        read(palabras, registroPalabra);
        insertarNodo(registroPalabra, listaRosco);
    end;
    enlazarNodos(listaRosco);
    close(palabras);
end;

function tienePalabrasPendientes(punteroJugador: punteroRosco): boolean;
var
    cursor: punteroRosco;
begin
    cursor:= punteroJugador^.siguiente;
    if (punteroJugador^.respuesta = 3) then
        tienePalabrasPendientes:= true;
    while (cursor^.respuesta <> 3) and (cursor <> punteroJugador) do
        punteroJugador:= punteroJugador^.siguiente;
    if (cursor^.respuesta = 3) then
        tienePalabrasPendientes:= true
    else
        tienePalabrasPendientes:= false;
end;

function primerPreguntaPendiente(var punteroJugador: punteroRosco): string;
begin
    while (punteroJugador^.respuesta <> 3) do
        punteroJugador:= punteroJugador^.siguiente;
    primerPreguntaPendiente:= punteroJugador^.consigna;
end;

procedure avanzarPreguntaPendiente(var punteroJugador: punteroRosco);
begin
    while (punteroJugador^.respuesta <> 3) do
        punteroJugador:= punteroJugador^.siguiente;
    ClrScr;
end;

procedure actualizarEstadoPreguntaCorrecta(var punteroJugador: punteroRosco);
begin
    punteroJugador^.respuesta:= 1;
end;

procedure actualizarEstadoPreguntaIncorrecta(var punteroJugador: punteroRosco);
begin
    punteroJugador^.respuesta:= 2;
end;

function respondioCorrectamente(respuesta, palabra: string): boolean;
begin
    if (respuesta = palabra) then
        respondioCorrectamente:= true
    else
        respondioCorrectamente:= false;
end;

procedure mostrarYContestarPregunta(var punteroJugador: punteroRosco);
var
    respuesta: string;
begin
    writeln(primerPreguntaPendiente(punteroJugador));
    writeln(' Letra ', punteroJugador^.letra);
    readln(respuesta);
    ClrScr;
    if (respuesta = 'pp') then
    begin
        avanzarPreguntaPendiente(punteroJugador);
        ClrScr;
    end
    else
        while (respondioCorrectamente(respuesta, punteroJugador^.palabra) = true) and (tienePalabrasPendientes(punteroJugador) = true) do
        begin
            actualizarEstadoPreguntaCorrecta(punteroJugador);
            writeln('    ¡Respuesta correcta! ');
            delay(1000);
            ClrScr;
            writeln(primerPreguntaPendiente(punteroJugador));
            writeln(' Letra ', punteroJugador^.letra);
            readln(respuesta);
            ClrScr;
        end;
        if (respondioCorrectamente(respuesta, punteroJugador^.palabra) = false) then
        begin
            actualizarEstadoPreguntaIncorrecta(punteroJugador);
            writeln('Respuesta incorrecta. ');
            delay(1000);
        end;
    ClrScr;
end;

function cantidadAcertada(punteroJugador: punteroRosco): integer;
var
    cursor: punteroRosco;
    cant: integer;
begin
    cant:= 0;
    if (punteroJugador^.respuesta = 1) then
        cant:= cant + 1;
    cursor:= punteroJugador^.siguiente;
    while (cursor^.respuesta <> 3) and (cursor <> punteroJugador) do
    begin
        if (cursor^.respuesta = 1) then
            cant:= cant + 1;
        cursor:= cursor^.siguiente;
    end;
    cantidadAcertada:= cant;
end;

procedure actualizarArchivo(var archivoJug: archivoJugadores; nombre: string); //ARREGLAR ARREGLAR ARREGLAR 
var
    dato: tipoJug;
begin
    reset(archivoJug);
    read(archivoJug, dato);
    while (dato.nombreJugador <> nombre) do
        Read(archivoJug, dato);
    dato.partidasGanadas:= dato.partidasGanadas + 1;
    seek(archivoJug, filepos(archivoJug) - 1);
    write(archivoJug, dato);
    close(archivoJug);
end;

procedure actualizarArbol(var arbolJugadores: punteroJugadores; nombre: string);
begin
    if (arbolJugadores <> nil) then
    begin
        if (arbolJugadores^.nombreJugador = nombre) then
            arbolJugadores^.partidasGanadas:= arbolJugadores^.partidasGanadas + 1
        else
            if (arbolJugadores^.nombreJugador < nombre) then
                actualizarArbol(arbolJugadores^.mayor, nombre)
            else
                actualizarArbol(arbolJugadores^.menor, nombre);
    end;
end;

procedure actualizarPartidasGanadas(var archivoJug: archivoJugadores; var arbolJugadores: punteroJugadores; nombre: string);
begin
    actualizarArbol(arbolJugadores, nombre);
    actualizarArchivo(archivoJug, nombre);
end;

procedure jugar(var arregloPartida: partida; var palabras: archivoPalabras; var arbolJugadores: punteroJugadores; var archivoJug: archivoJugadores);
var
    jugador1, jugador2: string;
    rosco1, rosco2: punteroRosco;
begin
    if (arbolJugadores = nil) or ((arbolJugadores^.mayor = nil) and (arbolJugadores^.menor = nil)) then
        writeln('Mínimo 2 jugadores para jugar. ')
    else
    begin
        ingresoJugador(jugador1, arbolJugadores);
        ingresoJugador(jugador2, arbolJugadores);
        while (jugador1 = jugador2) do
        begin
            writeln('Ingresó dos nombres iguales, ingrese de nuevo ambos jugadores');
            ingresoJugador(jugador1, arbolJugadores);
            ingresoJugador(jugador2, arbolJugadores);
        end;
        inicializarRosco(palabras, rosco1);
        arregloPartida[1].nombre:= jugador1;
        arregloPartida[1].rosco:= rosco1;
        inicializarRosco(palabras, rosco2);
        arregloPartida[2].nombre:= jugador2;
        arregloPartida[2].rosco:= rosco2;
        while (tienePalabrasPendientes(arregloPartida[1].rosco) = true) and (tienePalabrasPendientes(arregloPartida[2].rosco) = true) do
        begin
            ClrScr;
            writeln('      Turno de ', arregloPartida[1].nombre);
            mostrarYContestarPregunta(arregloPartida[1].rosco);
            ClrScr;
            writeln('      Turno de ', arregloPartida[2].nombre);
            mostrarYContestarPregunta(arregloPartida[2].rosco);
        end;
        if (cantidadAcertada(arregloPartida[1].rosco) > cantidadAcertada(arregloPartida[2].rosco)) then
        begin
            writeln('Ganó ', arregloPartida[1].nombre);
            actualizarPartidasGanadas(archivoJug, arbolJugadores, arregloPartida[1].nombre);
        end
        else
            if (cantidadAcertada(arregloPartida[1].rosco) < cantidadAcertada(arregloPartida[2].rosco)) then
            begin
                writeln('Ganó ', arregloPartida[2].nombre);
                actualizarPartidasGanadas(archivoJug, arbolJugadores, arregloPartida[2].nombre);
            end
            else
            begin
                writeln('Empate. ');
                presionarTecla();
            end;
    end;
    
end;

procedure verJugadores(arbolJugadores: punteroJugadores);
begin
    if (arbolJugadores <> nil) then
    begin
        verJugadores(arbolJugadores^.menor);
        writeln('Nombre: ', arbolJugadores^.nombreJugador, ' con ', arbolJugadores^.partidasGanadas,' partida/as ganadas. ');
        verJugadores(arbolJugadores^.mayor);
    end;
end;

procedure elegirOpcion(var opcion: integer);
begin
    TextColor(13);writeln('     PALAPASABRA');
    writeln('1. Agregar jugador.');
    writeln('2. Ver jugadores.');
    writeln('3. Jugar.');
    writeln('4. Salir.');
    write('Ingrese opción: ');
    readln(opcion);
    ClrScr;
end;

procedure mostrarMenu(var opcion: integer; var archivoJug: archivoJugadores; var arregloPartida: partida; var arbolJugadores: punteroJugadores; var palabras: archivoPalabras);
begin
    case opcion of
            1: agregarJugador(arbolJugadores, archivoJug);
            2: 
            begin
            if (arbolJugadores = nil) then
                writeln('No existen jugadores.')
            else
            begin
                writeln('Lista de jugadores: ');
                verJugadores(arbolJugadores);
            end;
            presionarTecla();
            end;
            3: jugar(arregloPartida, palabras, arbolJugadores, archivoJug); 
            4: writeln('Salir');
        else writeln('Opción inválida'); 
        delay(1000);
        ClrScr;
        end;
        elegirOpcion(opcion);
end;


//----------------------PROGRAMA PRINCIPAL----------------------
var
    archivoJug: archivoJugadores;
    arbolJugadores: punteroJugadores;
    arregloPartida: partida;
    palabras: archivoPalabras;
    opcion: integer;
begin
    crearArbol(arbolJugadores);
    assign(archivoJug, 'fcotti.dat');
    assign(palabras, '/ip2/palabras.dat');
    rewrite(archivoJug);
    elegirOpcion(opcion);
    while (opcion <> 4) do
        mostrarMenu(opcion, archivoJug, arregloPartida, arbolJugadores, palabras);
    writeln('Juego finalizado. Gracias por jugar. ');
    delay(1750);
end.