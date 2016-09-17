class Ab < Formula
  desc "Apache HTTP server benchmarking tool"
  homepage "https://httpd.apache.org/docs/trunk/programs/ab.html"
  url "https://archive.apache.org/dist/httpd/httpd-2.4.16.tar.bz2"
  sha256 "ac660b47aaa7887779a6430404dcb40c0b04f90ea69e7bd49a40552e9ff13743"
  revision 1

  bottle do
    cellar :any
    sha256 "b9a37c5df915197534c04faa1ddaaa31aba4f133dce9efe79e7e55dd85f1fc47" => :yosemite
    sha256 "86b08af96edbd95be2d8e5c75a7ce0997a60148fdf449d878d2b9f290f91d167" => :mavericks
    sha256 "6869c71b4de183dbf06a53396ea81c2f61680385187919a394b985845a69d6e1" => :mountain_lion
  end

  keg_only :provided_by_osx

  conflicts_with "httpd22", "httpd24", :because => "both install `ab`"

  option "with-ssl-patch", 'Apply patch for: Bug 49382 - ab says "SSL read failed"'

  depends_on "apr-util"
  depends_on "libtool" => :build

  # Disable requirement for PCRE, because "ab" does not use it
  patch :DATA

  # Patch for https://issues.apache.org/bugzilla/show_bug.cgi?id=49382
  # Upstream has not incorporated the patch. Should keep following
  # what upstream does about this.
  patch do
    url "https://gist.githubusercontent.com/Noctem/a0ba1477dbc11b5108b2/raw/ddf33c8a8b7939bbc3f12a1eb700a12b339d9194/ab-ssl-patch.diff"
    sha256 "6a71947075f733f73bdedaba27ea4e3c140bec95c63c01ab4f94b6794e0efe1c"
  end if build.with? "ssl-patch"

  def install
    # Mountain Lion requires this to be set, as otherwise libtool complains
    # about being "unable to infer tagged configuration"
    ENV["LTFLAGS"] = "--tag CC"
    system "./configure", "--prefix=#{prefix}", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--with-apr=#{Formula["apr"].opt_prefix}",
                          "--with-apr-util=#{Formula["apr-util"].opt_prefix}"

    cd "support" do
      system "make", "ab"
      bin.install "ab"
    end
    man1.install "docs/man/ab.1"
  end

  test do
    system "#{bin}/ab", "-k", "-n", "10", "-c", "10", "http://www.apple.com/"
  end
end

__END__
diff --git a/configure b/configure
index 90ae8be..243e9cf 100755
--- a/configure
+++ b/configure
@@ -6156,8 +6156,6 @@ $as_echo "$as_me: Using external PCRE library from $PCRE_CONFIG" >&6;}
     done
   fi
 
-else
-  as_fn_error $? "pcre-config for libpcre not found. PCRE is required and available from http://pcre.org/" "$LINENO" 5
 fi
 
   APACHE_VAR_SUBST="$APACHE_VAR_SUBST PCRE_LIBS"
