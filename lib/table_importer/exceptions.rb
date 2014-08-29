module TableImporter

  class ImportError < StandardError;
  end

  class EmptyFileImportError < ImportError
    def initialize(message = "The file you uploaded has no valid content to import or the content cannot be read. If there is content in your file please try copying and pasting it in instead.")
      super(message)
  	end
  end

  class EmptyStringImportError < ImportError
    def initialize(message = "The data you pasted in has no valid content to import or it cannot be read.")
      super(message)
    end
  end

  class IncorrectFileError < ImportError
    def initialize(message = "Sorry, you didn't upload the type of file you said you did.")
      super(message)
    end
  end

  class HeaderMismatchError < ImportError
    def initialize(message = "Sorry, we couldn't process your file. Did you correctly check whether your file has headers?")
      super(message)
    end
  end
end
