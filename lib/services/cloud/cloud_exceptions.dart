class CloudStorageException implements Exception{
  const CloudStorageException();
}
//C in CRUD
class CouldNotCreateNote extends CloudStorageException{}
//R in CRUD
class CouldNotGetAllNote extends CloudStorageException{}
//U in CRUD
class CouldNotUpdateNoteException extends CloudStorageException{}
//D in CRUD
class CouldNotDeleteNote extends CloudStorageException{}