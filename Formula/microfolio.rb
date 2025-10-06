class Microfolio < Formula
  url "https://github.com/aker-dev/microfolio/archive/refs/tags/v0.5.0-beta.8.tar.gz"
  sha256 "2a758f546898deffc931b0a5f921e623b50175047709827536070aedd9401f36"
  desc "Modern static portfolio generator for creatives (designers, architects, photographers)"
  homepage "https://github.com/aker-dev/microfolio"
  license "MIT"
  version_scheme 1

 # System dependencies - Node 22 LTS required
  depends_on "node@22"
  depends_on "pnpm"
  depends_on "git"

  def install
    # Install in libexec to avoid conflicts
    libexec.install Dir["*"]
    
    # Install Node.js dependencies
    cd libexec do
      system "pnpm", "install", "--frozen-lockfile"
    end
    
    # Main script to create and manage microfolio projects
    (bin/"microfolio").write <<~EOS
      #!/bin/bash
      
      # Help function
      show_help() {
        echo "microfolio - Static portfolio generator for creatives"
        echo ""
        echo "Usage:"
        echo "  microfolio new <project-name>     Create a new portfolio"
        echo "  microfolio dev                    Start development server"
        echo "  microfolio build                  Build site for production"
        echo "  microfolio preview                Preview built site locally"
        echo "  microfolio optimize-images        Generate WEBP thumbnails for all images"
        echo "  microfolio clean-images           Remove all WEBP thumbnails"
        echo "  microfolio help                   Show this help"
        echo ""
        echo "Examples:"
        echo "  microfolio new my-portfolio       # Creates new project in ./my-portfolio"
        echo "  cd my-portfolio && microfolio dev # Starts development server"
        echo "  microfolio optimize-images && microfolio build # Optimize images then build"
        echo "  microfolio build && microfolio preview # Build and preview production site"
        echo ""
      }
      
      # Check arguments
      case "$1" in
        "new")
          if [ -z "$2" ]; then
            echo "Error: Please specify a project name"
            echo "Usage: microfolio new <project-name>"
            exit 1
          fi
          
          if [ -d "$2" ]; then
            echo "Error: Directory '$2' already exists"
            exit 1
          fi
          
          echo "📁 Creating project '$2'..."
          
          # Create project directory
          mkdir "$2"
          cd "$2"
          
          # Clone the actual repository as template
          git clone https://github.com/aker-dev/microfolio.git temp_clone
          
          # Copy files from clone (excluding .git)
          cp -r temp_clone/* .
          cp -r temp_clone/.* . 2>/dev/null || true  # Copy hidden files, ignore errors
          
          # Clean up
          rm -rf temp_clone
          rm -rf .git
          
          # Initialize as new git repository
          git init
          git add .
          git commit -m "Initial commit - microfolio project"
          
          # Install dependencies
          echo "📦 Installing dependencies..."
          pnpm install
          
          echo "✅ Project '$2' created successfully!"
          echo ""
          echo "Next steps:"
          echo "  cd $2"
          echo "  microfolio dev"
          echo ""
          ;;
          
        "dev")
          if [ ! -f "package.json" ]; then
            echo "Error: No microfolio project detected in this folder"
            echo "Use 'microfolio new <name>' to create a new project"
            exit 1
          fi
          
          echo "🚀 Starting development server..."
          echo "Your site will be available at http://localhost:5173"
          echo "Press Ctrl+C to stop the server"
          echo ""
          exec pnpm dev
          ;;
          
        "build")
          if [ ! -f "package.json" ]; then
            echo "Error: No microfolio project detected in this folder"
            exit 1
          fi
          
          echo "🏗️  Building site..."
          exec pnpm build
          ;;
          
        "preview")
          if [ ! -f "package.json" ]; then
            echo "Error: No microfolio project detected in this folder"
            exit 1
          fi
          
          if [ ! -d "dist" ] && [ ! -d "build" ]; then
            echo "Error: No built site found. Run 'microfolio build' first."
            echo ""
            echo "Quick start:"
            echo "  microfolio build"
            echo "  microfolio preview"
            exit 1
          fi
          
          echo "👀 Starting preview server for built site..."
          echo "Your production site will be available at http://localhost:4173"
          echo "Press Ctrl+C to stop the server"
          echo ""
          exec pnpm preview
          ;;
          
        "optimize-images")
          if [ ! -f "package.json" ]; then
            echo "Error: No microfolio project detected in this folder"
            exit 1
          fi
          
          echo "🖼️  Optimizing images and generating WEBP thumbnails..."
          exec pnpm optimize-images
          ;;
          
        "clean-images")
          if [ ! -f "package.json" ]; then
            echo "Error: No microfolio project detected in this folder"
            exit 1
          fi
          
          echo "🧹 Cleaning WEBP thumbnails..."
          exec pnpm clean-images
          ;;
          
        "help"|"--help"|"-h"|"")
          show_help
          ;;
          
        *)
          echo "Unknown command: $1"
          echo ""
          show_help
          exit 1
          ;;
      esac
    EOS
  end

  def caveats
    <<~EOS
      To get started with microfolio:
      
      1. Create a new portfolio:
         microfolio new my-portfolio
      
      2. Go to the folder and start the server:
         cd my-portfolio
         microfolio dev
      
      3. Optimize images and build your production site:
         microfolio optimize-images
         microfolio build
         microfolio preview
      
      Available commands:
      - microfolio dev: Development server (http://localhost:5173)
      - microfolio build: Build for production
      - microfolio preview: Preview production site (http://localhost:4173)
      - microfolio optimize-images: Generate WEBP thumbnails
      - microfolio clean-images: Remove WEBP thumbnails
      
      Full documentation: https://github.com/aker-dev/microfolio
    EOS
  end

  test do
    # Test creating a new project
    system bin/"microfolio", "new", "test-portfolio"
    assert_predicate testpath/"test-portfolio/package.json", :exist?
    assert_predicate testpath/"test-portfolio/content", :exist?
    
    # Test that dependencies are installed
    cd "test-portfolio" do
      assert_predicate Pathname.pwd/"node_modules", :exist?
    end
    
    # Test help
    assert_match "microfolio - Static portfolio generator", 
                 shell_output("#{bin}/microfolio help")
  end
end