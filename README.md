# Práctica BDCA

## _

### Todo

- [x] Constructor con dos parámetros - nombre asignatura y curso
- [x] Propiedad owner para usuario que ha desplegado el contrato immutable
- [x] Métodos para consultar nombre, curso y dirección de owner - public
- [x] Método receive para impedir enviar dinero al contrato
- [x] Propiedad coordinador para guardar dirección y pública
- [x] Crear un método llamado setCoordinator
- [x] Crear propiedad booleana cerrada
- [x] No se pueden matricular nuevos alumnos, ni añadir profesores, ni evaluaciones ni ponerse notas - con modifiers
- [x] Crear un método cerrar para cerrar la asignatura
- [x] Crear el método addProfesor, donde pasamos el address y el nombre
- [x] addProfesor name no puede ser vacío, un profesor no se puede añadir varias veces
- [x] guardamos datos en mapping datosProfesor publico
- [x] guardamos las direcciones en un array público llamado profesores
- [x] creamos el método llamado profesores length
- [ ] crear método automatrícula, tiene como argumentos nombre, dni, y email. No se puede meter dni o nombre vacío, el dni tiene que ser único.
- [ ] El owner también puede matricular, con el método matricular, con las mismas restricciones que el caso anterior
- [ ] hacer un mapping público datosAlumno, con la dirección retorna el struct (nombre, dni, email)
- [ ] las direcciones de usuario se guardan en matriculas
- [ ] creamos matrículasLength como método para saber los alumnos matriculadors
- [ ] creamos el método quien soy, nos devuelve el nombre, dni, email del alumno que ha invocado el método.
- [ ] Creamos el método creaEvaluación para crear una prueba de evaluación. Toma como argumentos el nombre, la fecha de evaluación, el porcentaje de la nota que representa, la nota mínima (x100)
- [ ] metemos las evaluaciones en un array de evaluaciones
- [ ] el método creaEvaluación nos retorna el index de la evaluación creada
- [ ] creamos un método evaluacionesLength que devuelve el número de evaluaciones creadas
- [ ] creamos el método califica con cuatro parámetros, dirección del alumno, índice de una evaluación, tipo de nota (Enum), un uint para nota sin decimales (7.25 == 725)
- [ ] se guardan las notas en mapping llamado calificaciones, con esta estructura mapping(address => mapping(uint => uint)), siendo (ad => (index => nota))
- [ ] mapping calificaciones tiene que se público y toma como args la dirección y el índice
- [ ] crear el método miNota, devuelve el tipo de nota y la calificación desde el address del alumno y la index de la evaluación
- [ ] crear el método miNotaFinal es un método para consultar la nota final. Devuelve el tipo de calificación y la calificación multiplicada por 100
- [ ] crear el método notaFinal para que el coordinador pueda consultar la nota de un alumno, toma la dirección del alumno como parámetro, y retorna lo mismo que lo anterior
- [ ] Si el tipo de nota de alguna de las calificaciones es empty, se retorna en general (Empty, 0)
- [ ] Si todas las calificaciones son de tipo NP, se retorna NP, 0
- [ ] Si la nota final es superior a 499, pero alguna calificación es NP, se retorna 499
- [ ] creamos modificador soloOwner para que los métodos setCoordinador, addProfesor y matricular solo pueda ejecutarlas el owner
- [ ] creamos modificador soloCoordinador para que notaFinal, cerrar y creaEvaluación solo pueda el coordinador
- [ ] soloProfesor para califica
- [ ] soloMatriculados para quienSoy, miNota y miNotaFinal
- [ ] soloNoMatriculador para que automatricula solo pueda ejecturla alguien que no está matriculado
- [ ] soloAbierta para que setCoordinador, addProfesor, automatricula, creaEvaluación y califica puedan ejecutarse si cerrada == false
- [ ] Crear un error personalizadocuando se intenta matricular un alumno con un dni existente, usarlo en método automatrícula
