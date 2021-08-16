class KubernetesHelm261 < Formula
  # Should move to helm 2.17 (https://github.com/Homebrew/homebrew-core/blob/master/Formula/helm@2.rb) for 2.x
  # Or https://github.com/Homebrew/homebrew-core/blob/master/Formula/helm.rb for 3.x
  # helm 2.x is getting deprecated soon so shold move to heml 3.x
  desc "The Kubernetes package manager"
  homepage "https://helm.sh/"
  url "https://github.com/kubernetes/helm.git",
      :tag => "v2.6.1",
      :revision => "bbc1f71dc03afc5f00c6ac84b9308f8ecb4f39ac"
  head "https://github.com/kubernetes/helm.git"

  bottle do
    sha256 cellar: :any_skip_relocation, sierra:     "aac19ad1d1d3ff9c015b7f7556a8e8cd12bf0807ac8e2e8c915513a89c3b2477"
    sha256 cellar: :any_skip_relocation, el_capitan: "49b6eca7c0dc1d77f496c8e616da32f53fb13eafbdfd49a499bb259543cd6f15"
    sha256 cellar: :any_skip_relocation, yosemite:   "f364169da5dee273b9a05fbb77cbd0a9fa508508edcbea224311a69754648e95"
  end

  depends_on "mercurial" => :build
  depends_on "go" => :build
  depends_on "glide" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GLIDE_HOME"] = HOMEBREW_CACHE/"glide_home/#{name}"
    ENV.prepend_create_path "PATH", buildpath/"bin"
    arch = Hardware::CPU.is_64_bit? ? "amd64" : "x86"
    ENV["TARGETS"] = "darwin/#{arch}"
    dir = buildpath/"src/k8s.io/helm"
    dir.install buildpath.children - [buildpath/".brew_home"]

    cd dir do
      # Bootstap build
      system "make", "bootstrap"

      # Make binary
      system "make", "build"
      bin.install "bin/helm"
      bin.install "bin/tiller"

      # Install man pages
      man1.install Dir["docs/man/man1/*"]

      # Install bash completion
      bash_completion.install "scripts/completions.bash" => "helm"
    end
  end

  test do
    system "#{bin}/helm", "create", "foo"
    assert File.directory? "#{testpath}/foo/charts"

    version_output = shell_output("#{bin}/helm version --client 2>&1")
    assert_match "GitTreeState:\"clean\"", version_output
    assert_match stable.instance_variable_get(:@resource).instance_variable_get(:@specs)[:revision], version_output if build.stable?
  end
end
